//
//  BPFile.m
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 5/30/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPFile.h"
#import "BPApi.h"
#import "BPRecord.h"
#import "BPConfig.h"
#import "BPSession.h"
#import "BPSigner.h"

@interface BPFile()

@property NSData *data;

@property (strong) NSString *record_endpoint;
@property (strong) NSString *record_id;

@property (strong) NSDictionary *dictionary_data;

@property (strong) NSString *presigned_url;
@property (strong) NSNumber *presigned_expiration;

@end

@implementation BPFile

-(instancetype)initWithRecord:(BPObject *)record data:(NSData *)data andName:(NSString *)name
{
    self = [super init];
    if(self) {
        self.record_id = record.objectId;
        self.record_endpoint = ((BPRecord *)record).endpoint_name;
        self.endpoint_name = name;
        self.data = data;
        self.name = name;
        self.dictionary_data = @{@"name": self.name, @"size": @0};
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary andRecord:(BPObject *)record
{
    self = [super init];
    if(self) {
        self.record_id = record.objectId;
        self.record_endpoint = ((BPRecord *)record).endpoint_name;
        self.endpoint_name = dictionary[@"name"];
        self.objectId = dictionary[@"id"];
        self.size = dictionary[@"size"];
        self.name = dictionary[@"name"];
        self.presigned_url = dictionary[@"presigned_url"];
        self.presigned_expiration = dictionary[@"presigned_expiration"];
        self.dictionary_data = @{@"name": self.name, @"size": self.size};
    }
    return self;
}

-(void)uploadWithBlock:(void (^)(NSError *))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/%@/files", self.record_endpoint, self.record_id];
    
    self.size = @((self.data).length);
    
    NSDictionary *request = @{
    @"file": @{
        @"size": self.size,
        @"name": self.name
      }
    };
    self.dictionary_data = @{@"name": self.name, @"size": self.size};

    [BPApi post:url withData:request andBlock:^(NSError *error, id responseObject) {
        if(!error) {
            NSDictionary *file = responseObject[@"response"][@"files"][0];
            self.objectId = file[@"id"];
            NSString *url = file[@"upload_request"][@"url"];
            NSDictionary *params = file[@"upload_request"][@"params"];
            [self uploadFileWithURL:url params:params andBlock:completionBlock];
        }
    }];
}

-(void)destroyWithBlock:(void (^)(NSError *))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/%@/files/%@/destroy", self.record_endpoint, self.record_id, self.objectId];

    [BPApi post:url withData:@{} andBlock:^(NSError *error, id responseObject) {
        completionBlock(error);
    }];
}

-(NSURL *)downloadURL
{
    NSMutableString *path = [NSMutableString stringWithFormat:@"%@/%@/files/%@",
                             self.record_endpoint, self.record_id, self.objectId];
    
    if(self.presigned_url && ((NSNumber *)self.presigned_expiration).intValue > [NSDate new].timeIntervalSince1970) {
        return [NSURL URLWithString:self.presigned_url];
    } else {
        if([BPSession user_id]) {
            int timestamp = [NSDate date].timeIntervalSince1970;
            NSString *session_id = [BPSession session_id];
            NSString *auth_token = [BPSession auth_token];
            NSString *signature_string = [NSString stringWithFormat:@"%i%@", timestamp, self.objectId];
            NSString *signature = [BPSigner signString:signature_string withKey:auth_token];
            
            [path appendFormat:@"?timestamp=%i", timestamp];
            [path appendFormat:@"&session_id=%@", session_id];
            [path appendFormat:@"&signature=%@", signature];
        }

        return [BPApi buildURLWithPath:path];
    }
}

-(void)uploadFileWithURL:(NSString *)url_string params:(NSDictionary *)params andBlock:(void(^)(NSError *error))block
{
    NSURL *url = [NSURL URLWithString:url_string];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";

    NSString *boundary = [NSString stringWithFormat:@"---------------------------BPMRQ%@", self.objectId];
    
    NSMutableData *body = [[NSMutableData alloc] init];
    
    NSArray *keys = params.allKeys;
    keys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for(NSString *key in keys) {
        body = [self appendObject:params[key] forKey:key toBody:body withBoundary:boundary];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", self.endpoint_name]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:self.data];

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPBody = body;

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        block(error);
    }];
    
    [task resume];
}

-(NSMutableData *)appendObject:(NSString *)string forKey:(NSString *)key toBody:(NSMutableData *)body withBoundary:(NSString *)boundary
{
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, string] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

-(NSArray *)allKeys
{
    return self.dictionary_data.allKeys;
}

-(NSUInteger)count
{
    return self.dictionary_data.count;
}

-(NSEnumerator *)keyEnumerator
{
    return self.dictionary_data.keyEnumerator;
}

-(id)objectForKey:(id)aKey
{
    return self.dictionary_data[aKey];
}

@end
