//
//  SFRequest.m
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPRequest.h"

@implementation BPRequest

+(void)sendRequestWithURL:(NSURL *)url
                   method:(NSString *)method
                     data:(NSDictionary *)data
                 andBlock:(void(^)(NSError *error, NSDictionary *data))block
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;
    
    NSError *json_serialize_error = nil;
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:0 error:&json_serialize_error];
    
    if(json_serialize_error != nil) {
        block(json_serialize_error, nil);
        
    } else {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable response_data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
            
            NSError *json_read_error = nil;
            NSDictionary *response_dictionary = [NSJSONSerialization JSONObjectWithData:response_data options:0 error:&json_read_error];
            if(json_read_error != nil) {
                block(json_read_error, nil);
            } else {
                block(nil, response_dictionary);
            }
        }];
        
        [task resume];
    }
}


@end
