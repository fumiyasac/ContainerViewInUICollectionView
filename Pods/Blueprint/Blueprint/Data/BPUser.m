//
//  SFUser.m
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPUser.h"
#import "BPApi.h"
#import "BPAuth.h"
#import "BPSession.h"


@implementation BPUser

+(void)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
                    andBlock:(void(^)(NSError *error, NSDictionary *data))block;
{
    [BPAuth authenticateWithEmail:email password:password andBlock:block];
}

+(void)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token
                         andBlock:(void(^)(NSError *error, NSDictionary *data))block
{
    [BPAuth authenticateWithFacebookId:facebook_id facebookToken:facebook_token andBlock:block];
}

+(void)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken
                     andBlock:(void (^)(NSError *, NSDictionary *))block
{
    [BPAuth authenticateWithUserID:user_id transferToken:transferToken andBlock:block];
}

+(void)logout
{
    [BPUser logoutWithBlock:^(BOOL success, NSError *error) {
        
    }];
}

+(void)logoutWithBlock:(void (^)(BOOL, NSError *))completionBlock
{
    [BPSession destroySession];
    completionBlock(true, nil);
}


+(void)registerUserWithEmail:(NSString *)email
                    password:(NSString *)password
                     andName:(NSString *)name
                   withBlock:(void (^)(BOOL, NSError *))completionBlock
{
    NSDictionary *data = @{
                           @"user": @{
                                   @"email": email,
                                   @"password": password,
                                   @"name": name
                                   }
                           };
    [BPApi post:@"users" withData:data andBlock:^(NSError *error, id responseObject) {
        if(error == nil) {
            NSDictionary *data = (NSDictionary *)responseObject;
            NSDictionary *user = data[@"response"][@"users"][0];
            
            [[BPSession sharedSession] setSession:@{
                                                    @"auth_token": user[@"auth_token"],
                                                    @"user_id": user[@"id"],
                                                    @"session_id": user[@"session_id"]
                                                    }];
            
        }
        completionBlock([BPSession sharedSession].isSessionActive, error);
    }];
}

+(void)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name
                    withBlock:(void (^)(BOOL, NSError *))completionBlock
{
    NSDictionary *data = @{
                           @"user": @{
                                   @"facebook_id": facebook_id,
                                   @"facebook_token": facebook_token,
                                   @"name": name,
                                   @"email": email
                                   }
                           };
    [BPApi post:@"users" withData:data andBlock:^(NSError *error, id responseObject) {
        if(error == nil) {
            NSDictionary *data = (NSDictionary *)responseObject;
            NSDictionary *user = data[@"response"][@"users"][0];
            
            [[BPSession sharedSession] setSession:@{
                                                    @"auth_token": user[@"auth_token"],
                                                    @"user_id": user[@"id"],
                                                    @"session_id": user[@"session_id"]
                                                    }];
            
        }
        completionBlock([BPSession sharedSession].isSessionActive, error);
    }];
}

-(void)updateWithData:(NSDictionary *)data andBlock:(void (^)(NSError *error))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"users/%@", self.objectId];
    
    [BPApi put:url withData:@{@"user":data} andBlock:^(NSError *error, id responseObject) {
        completionBlock(error);
    }];
}

-(void)destroyUserWithBlock:(void (^)(NSError *))block
{
    NSString *url = [NSString stringWithFormat:@"users/%@/destroy", self.objectId];
    
    [BPApi post:url withData:@{} andBlock:^(NSError *error, id responseObject) {
        block(error);
    }];
}

@end
