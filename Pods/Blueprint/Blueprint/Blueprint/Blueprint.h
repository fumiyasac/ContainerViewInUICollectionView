//
//  Blueprint.h
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 5/30/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPGroup.h"
#import "BPModel.h"
#import "BPProfile.h"
#import "BPError.h"

//! Project version number for Blueprint Cocoa.
FOUNDATION_EXPORT double BlueprintVersionNumber;

//! Project version string for Blueprint Cocoa.
FOUNDATION_EXPORT const unsigned char BlueprintVersionString[];

@interface Blueprint : NSObject

+(void)setConfig:(NSDictionary *)config;

+(void)setProfileClass:(Class)klass;

#pragma mark - BPUser

+(void)registerWithEmail:(NSString *)email
                password:(NSString *)password
                    name:(NSString *)name
                andBlock:(void(^)(NSError *error))block;

+(void)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name
                     andBlock:(void(^)(NSError *error))block;

+(void)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
                    andBlock:(void(^)(NSError *error, NSDictionary *data))block;

+(void)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token
                         andBlock:(void(^)(NSError *error, NSDictionary *data))block;


+(void)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken
                     andBlock:(void(^)(NSError *error, NSDictionary *data))block;


+(void)destroyCurrentUserWithBlock:(void(^)(NSError *error))block;

+(void)updateUserPassword:(NSString *)password currentPassword:(NSString *)current_password withBlock:(void(^)(NSError *error))block;
+(void)updateUserEmail:(NSString *)email withBlock:(void(^)(NSError *error))block;


#pragma mark - BPGroup
+(BPGroup *)publicGroup;
+(BPGroup *)privateGroup;

#pragma mark - BPProfile
+(void)getProfileForUserWithId:(NSString *)user_id
                     withBlock:(void(^)(NSError *error, BPProfile *profile))block;

+(void)getCurrentUserProfileWithBlock:(void(^)(NSError *error, BPProfile *profile))block;
+(void)reloadCurrentUserProfileWithBlock:(void(^)(NSError *, BPProfile *))block;

+(BPProfile *)cachedProfile;

#pragma mark - BPSession
+(BOOL)restoreSession;
+(NSString *)currentUserId;
+(void)destroySession;

+(void)setErrorHandler:(errorBlock)block;

#pragma mark - Bulk Requests
+(void)enableBulkRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time;
+(void)runBulkRequests;
+(void)disableBulkRequests;
@end