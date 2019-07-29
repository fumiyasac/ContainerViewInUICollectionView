//
//  BPAuth.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPAuth.h"
#import "BPApi.h"
#import "BPSession.h"
#import "BPSigner.h"
#import "BPConfig.h"
#import "BPOrderedDictionary.h"

@implementation BPAuth

+(NSMutableDictionary *)signRequest:(NSMutableDictionary *)request
                               path:(NSString *)path
                          andMethod:(NSString *)method
{
    NSNumber *timestamp = [NSNumber numberWithInt:[NSDate date].timeIntervalSince1970];
    
    NSString *guid = [NSUUID UUID].UUIDString;
    
    request[@"authorization"] = @{
        @"user_id": [BPSession user_id],
        @"session_id": [BPSession session_id],
        @"timestamp": timestamp,
        @"guid": guid,
    }.mutableCopy;
    
    request[@"authorization"][@"signature"] = [BPAuth signatureForRequest:request
                                                                     path:path
                                                                andMethod:method];
    return request;
}

+(void)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
                    andBlock:(void(^)(NSError *error, NSDictionary *data))block;
{
    NSDictionary *data = @{
       @"user": @{
            @"email": email,
            @"password": password
       }
    };
    
    [BPApi post:@"users/authenticate" withData:data andBlock:^(NSError *error, NSDictionary *data) {
        if(!error) {
            NSDictionary *user = data[@"response"][@"users"][0];

            [[BPSession sharedSession] setSession:@{
                @"auth_token": user[@"auth_token"],
                @"user_id": user[@"id"],
                @"session_id": user[@"session_id"]
            }];
        }
        
        block(error, data);
    }];
}

+(void)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token
                         andBlock:(void(^)(NSError *error, NSDictionary *data))block
{
    NSDictionary *data = @{
       @"user": @{
               @"facebook_id": facebook_id,
               @"facebook_token": facebook_token
       }
    };
    
    [BPApi post:@"users/authenticate" withData:data andBlock:^(NSError *error, NSDictionary *data) {
        if(!error) {
            NSDictionary *user = data[@"response"][@"users"][0];
            
            [[BPSession sharedSession] setSession:@{
                @"auth_token": user[@"auth_token"],
                @"user_id": user[@"id"],
                @"session_id": user[@"session_id"]
            }];
        }
        
        block(error, data);
    }];
}


+(void)authenticateWithUserID:(NSString *)user_id
                transferToken:(NSString *)transfer_token
                     andBlock:(void (^)(NSError *, NSDictionary *))block
{
    NSDictionary *data = @{
                           @"user": @{
                                   @"transfer_id": user_id,
                                   @"transfer_token": transfer_token
                                   }
                           };
    
    [BPApi post:@"users/authenticate" withData:data andBlock:^(NSError *error, NSDictionary *data) {
        if(!error) {
            NSDictionary *user = data[@"response"][@"users"][0];
            
            [[BPSession sharedSession] setSession:@{
                                                    @"auth_token": user[@"auth_token"],
                                                    @"user_id": user[@"id"],
                                                    @"session_id": user[@"session_id"]
                                                    }];
        }
        
        block(error, data);
    }];
}

+(NSString *)signatureForRequest:(NSDictionary *)request
                            path:(NSString *)path
                       andMethod:(NSString *)method
{
    NSDictionary *request_dict = [BPAuth sortDictionary:request[@"request"]];
    
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:request_dict
                                                        options:0
                                                          error:nil];
    
    NSString *json = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];

    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendString:((NSNumber *)request[@"authorization"][@"timestamp"]).stringValue];
    [message appendString:(NSString *)request[@"authorization"][@"guid"]];
    [message appendString:(NSString *)path];
    [message appendString:(NSString *)method];
    [message appendString:json];

    return [BPSigner signString:message
                        withKey:(NSString *)[BPSession objectForKey:@"auth_token"]];
}

+(NSDictionary *)sortDictionary:(NSDictionary *)dictionary
{

    NSArray *keys = [dictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2 options:NSLiteralSearch];
    }];
    
    NSMutableArray *objects = @[].mutableCopy;
    
    for(NSString *key in keys) {
        if([[dictionary[key] class] isSubclassOfClass:[NSDictionary class]]) {
            [objects addObject:[BPAuth sortDictionary:dictionary[key]]];
        } else if([[dictionary[key] class] isSubclassOfClass:[NSArray class]]) {
            NSMutableArray *array = @[].mutableCopy;
            
            for(NSObject *value in dictionary[key]) {
                if([[value class] isSubclassOfClass:[NSDictionary class]]) {
                    [array addObject:[BPAuth sortDictionary:(NSDictionary *)value]];
                } else {
                    [array addObject:value];
                }
            }
            
            [objects addObject:array];
        } else {
            [objects addObject:dictionary[key]];
        }
    }
    
    return [BPOrderedDictionary dictionaryWithObjects:objects forKeys:keys];
}

@end
