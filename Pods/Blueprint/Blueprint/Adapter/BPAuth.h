//
//  BPAuth.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPAuth : NSObject
+(NSMutableDictionary *)signRequest:(NSMutableDictionary *)request
                               path:(NSString *)path
                          andMethod:(NSString *)method;

+(void)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
                    andBlock:(void(^)(NSError *error, NSDictionary *data))block;

+(void)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token
                         andBlock:(void(^)(NSError *error, NSDictionary *data))block;

+(void)authenticateWithUserID:(NSString *)user_id
                transferToken:(NSString *)transfer_token
                     andBlock:(void(^)(NSError *error, NSDictionary *data))block;

@end
