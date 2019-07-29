//
//  SFUser.h
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPObject.h"

@interface BPUser : BPObject

@property (nonatomic, copy, readonly) NSString *authenticationToken;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *sessionId;


+(void)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
                    andBlock:(void(^)(NSError *error, NSDictionary *data))block;

+(void)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token
                         andBlock:(void(^)(NSError *error, NSDictionary *data))block;

+(void)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken
                     andBlock:(void(^)(NSError *error, NSDictionary *data))block;

+(void)logout;
+(void)logoutWithBlock:(void (^)(BOOL success, NSError *error))completionBlock;

+(void)registerUserWithEmail:(NSString *)email
                    password:(NSString *)password
                     andName:(NSString *)name
                   withBlock:(void (^)(BOOL, NSError *))completionBlock;

+(void)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name
                    withBlock:(void (^)(BOOL, NSError *))completionBlock;

-(void)destroyUserWithBlock:(void (^)(NSError *))block;

-(void)updateWithData:(NSDictionary *)data
             andBlock:(void (^)(NSError *error))completionBlock;



@end
