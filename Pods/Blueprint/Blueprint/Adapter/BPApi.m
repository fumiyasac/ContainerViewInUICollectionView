//
//  BPApi.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPApi.h"
#import "BPHTTP.h"
#import "BPSession.h"
#import "BPAuth.h"
#import "BPConfig.h"

@implementation BPApi

static NSMutableArray *bulk_request_pool;
static bool bulk_requests_enabled;
static bool bulk_requests_active;

static int bulk_request_idle_time;
static int bulk_request_max_time;

static NSTimer *bulk_request_idle_timer;
static NSTimer *bulk_request_max_timer;

typedef void (^bphttp_block)(NSError *, id data);

+(void)post:(NSString *)path
   withData:(NSDictionary *)data
   andBlock:(void(^)(NSError *error, id responseObject))block
{
    [self post:path withData:data authenticated:YES andBlock:block];
}

+(void)put:(NSString *)path
  withData:(NSDictionary *)data
  andBlock:(void(^)(NSError *error, id responseObject))block
{
    [self put:path withData:data authenticated:YES andBlock:block];
}

+(void)post:(NSString *)path
   withData:(NSDictionary *)data
authenticated:(BOOL)authenticated
   andBlock:(void(^)(NSError *error, id responseObject))block
{
    bool send = true;
        
    if(bulk_requests_enabled && [path containsString:@"/query"] && authenticated == YES) {
        [BPApi addBulkRequest:@{@"path": path, @"data": data, @"block": block}];
        send = NO;
    }
    
    if(send) {
        [BPApi sendRequestWithPath:path
                            method:@"POST"
                              data:data
                     authenticated:authenticated
                          andBlock:block];
    }
}

+(void)put:(NSString *)path
  withData:(NSDictionary *)data
authenticated:(BOOL)authenticated
  andBlock:(void(^)(NSError *error, id responseObject))block
{
    [BPApi sendRequestWithPath:path
                        method:@"PUT"
                          data:data
                 authenticated:authenticated
                      andBlock:block];
}

// Private Helper Methods

+(void)sendRequestWithPath:(NSString *)path
                   method:(NSString *)method
                     data:(NSDictionary *)data
             authenticated:(BOOL)authenticated
                 andBlock:(void(^)(NSError *error, id data))block
{
    NSURL *url = [BPApi buildURLWithPath:path];
    
    NSMutableDictionary *request_data = @{@"request":data}.mutableCopy;
    
    if(authenticated && [BPSession objectForKey:@"auth_token"] != nil) {
        request_data = [BPAuth signRequest:request_data path:url.path andMethod:method];
    }
    
    [BPHTTP sendRequestWithURL:url method:method data:request_data andBlock:block];
}

+(NSURL *)buildURLWithPath:(NSString *)path
{
    NSString *url;
    
    url = [NSString stringWithFormat:@"%@://%@:%@/%@/%@",
        [BPConfig protocol],
        [BPConfig host],
        [BPConfig port],
        [BPConfig application_id],
        path];

    return [[NSURL alloc] initWithString:url];
}

#pragma mark - Bulk Requests
+(void)sendBulkRequest:(NSArray *)requests
{
    if(requests.count == 1) {
        [BPApi sendRequestWithPath:requests[0][@"path"] method:@"POST" data:requests[0][@"data"] authenticated:YES andBlock:requests[0][@"block"]];
    } else if(requests.count != 0) {
        NSMutableArray *formatted_requests = @[].mutableCopy;
        
        NSMutableArray *guid_array = @[].mutableCopy;
        
        for(NSDictionary *request in requests) {
            NSString *guid = [NSUUID UUID].UUIDString;

            if(guid && [request[@"path"] componentsSeparatedByString:@"/"][0] && request[@"data"]) {
                [formatted_requests addObject:@{
                    @"endpoint": [request[@"path"] componentsSeparatedByString:@"/"][0],
                    @"request": request[@"data"],
                    @"guid": guid
                }];
                
                [guid_array addObject:guid];
            }
        }
        
        NSDictionary *data = @{@"requests": formatted_requests}.mutableCopy;
        
        NSString *url_string = [NSString stringWithFormat:@"%@://%@:%@/%@/%@",
               [BPConfig protocol],
               [BPConfig host],
               [BPConfig port],
               [BPConfig application_id],
               @"bulk_query"];

        NSURL *url = [NSURL URLWithString:url_string];
        
        NSMutableDictionary *request_data = @{@"request":data}.mutableCopy;
        
        if([BPSession objectForKey:@"auth_token"] != nil) {
            request_data = [BPAuth signRequest:request_data path:url.path andMethod:@"POST"];
        }
        
        [BPHTTP sendRequestWithURL:url method:@"POST" data:request_data andBlock:^(NSError *error, id data) {
            NSDictionary *dict = data;
            
            NSMutableDictionary *blocks = @{}.mutableCopy;
            
            for(NSDictionary *request in requests) {
                blocks[guid_array[[requests indexOfObject:request]]] = ((bphttp_block)request[@"block"]);
            }
            
            for(NSString *guid in  [dict[@"response"] allKeys]) {
                NSDictionary *response = dict[@"response"][guid];
                NSNumber *record_count = dict[@"meta"][[NSString stringWithFormat:@"%@.record_count", guid]];

                if(record_count == nil) {
                    record_count = @0;
                }
                
                bphttp_block block = ((bphttp_block)blocks[guid]);
                
                if(block != nil) {
                    if(response == nil) {
                        NSError *error = [[NSError alloc] initWithDomain:@"co.goblueprint.error"
                                                                    code:100
                                                                userInfo:nil];
                        
                        block(error, @{});
                    } else {
                        NSDictionary *d = @{@"response": response, @"meta":@{@"record_count": record_count}};
                        block(nil, d);
                    }
                }
            }
        }];
    }
}

+(void)addBulkRequest:(NSDictionary *)request
{
    bulk_requests_active = YES;
    
    if(bulk_request_pool == nil) {
        bulk_request_pool = @[].mutableCopy;
    }
    
    @synchronized(bulk_request_pool) {
        [bulk_request_pool addObject:request];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(bulk_request_idle_timer) {
            [bulk_request_idle_timer invalidate];
        }

        bulk_request_idle_timer = [NSTimer scheduledTimerWithTimeInterval:bulk_request_idle_time/1000 target:self selector:@selector(runBulkRequests) userInfo:nil repeats:NO];
        
        if(bulk_request_max_timer == nil) {
            bulk_request_max_timer = [NSTimer scheduledTimerWithTimeInterval:bulk_request_max_time/1000 target:self selector:@selector(runBulkRequests) userInfo:nil repeats:NO];
        }
    });
}

+(void)enableBulkRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time
{
    bulk_request_idle_time = idle_time;
    bulk_request_max_time = max_collection_time;
    bulk_requests_enabled = true;
}

+(void)runBulkRequests
{
    [bulk_request_max_timer invalidate];
    [bulk_request_idle_timer invalidate];
    
    bulk_request_max_timer = nil;
    bulk_request_idle_timer = nil;
    
    bulk_requests_active = NO;

    @synchronized(bulk_request_pool) {
        [BPApi sendBulkRequest:bulk_request_pool];
        bulk_request_pool = @[].mutableCopy;
    }
}

+(void)disableBulkRequests
{
    bulk_requests_enabled = NO;
    [BPApi runBulkRequests];
}

@end

