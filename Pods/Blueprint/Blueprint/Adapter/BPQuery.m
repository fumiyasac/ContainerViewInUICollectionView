//
//  BPQuery.m
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 6/1/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPQuery.h"
#import "BPApi.h"

@implementation BPQuery

@synthesize endpoint = _endpoint;

- (instancetype)initWithEndpoint:(NSString *)name
{
    self = [super init];
    if (self) {
        
        _endpoint = name;
    }
    return self;
}

+ (BPQuery *)queryForEndpoint:(NSString *)name
{
    return [[BPQuery alloc] initWithEndpoint:name];
}

- (void)findRecordsWhere:(NSDictionary *)where withBlock:(void (^)(NSError *error, NSArray *objects))completionBlock
{
    [self findDataWhere:where withBlock:^(NSError *error, NSArray *response) {
        NSMutableArray *objects = @[].mutableCopy;
        if(!error) {
            for(NSDictionary *json in response) {
                BPRecord *record = [BPRecord recordWithEndpointName:_endpoint andContent:json];
                [objects addObject:record];
            }
        }
        completionBlock(error, objects);
    }];
}

- (void)findDataWhere:(NSDictionary *)where withBlock:(void (^)(NSError *error, NSArray *objects))completionBlock
{
    [self findDataWhere:where withBlock:completionBlock andRetryCount:0];
}

- (void)findDataWhere:(NSDictionary *)where
            withBlock:(void (^)(NSError *error, NSArray *objects))completionBlock
        andRetryCount:(int)retry_count
{
    NSDictionary *request = @{ @"where" : where};
    
    NSString *path = [NSString stringWithFormat:@"%@/query",self.endpoint];
    [BPApi post:path withData:request andBlock:^(NSError *error, id responseObject) {
        if(error) {
            if(retry_count > 2) {
                completionBlock(error, @[]);
            } else {
                [self findDataWhere:where withBlock:completionBlock andRetryCount:(retry_count+1)];
            }
        } else {
            NSArray *objects = responseObject[@"response"][_endpoint];
            if([objects isEqual:[NSNull null]]) {
                objects = @[];
            }
            
            completionBlock(error, objects);
        }
    }];
}

@end
