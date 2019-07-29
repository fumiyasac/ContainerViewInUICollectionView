//
//  Blueprint.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "Blueprint.h"
#import "BPUser.h"
#import "BPConfig.h"
#import "BPSession.h"
#import "BPApi.h"

@implementation Blueprint

static BPProfile *cachedProfile;
static Class profileClass;

static NSMutableArray *profileLoadObservers;

static bool loadingProfile;

#pragma mark - BPConfig

+(void)setConfig:(NSDictionary *)config
{
    [BPConfig setConfig:config];
}

+(void)setProfileClass:(Class)klass
{
    profileClass = klass;
}

+(Class)profileClass
{
    if(profileClass == nil) {
        return [BPProfile class];
    } else {
        return profileClass;
    }
}

#pragma mark - BPUser

+(void)registerWithEmail:(NSString *)email
                password:(NSString *)password
                    name:(NSString *)name
                andBlock:(void(^)(NSError *error))block;
{
    if([Blueprint currentUserId]) {
        block(nil);
    } else {
        [BPUser registerUserWithEmail:email
                             password:password
                              andName:name
                            withBlock:^(BOOL success, NSError *error) {
                                block(error);
        }];
    }
}

+(void)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name
                     andBlock:(void(^)(NSError *error))block;
{
    if([Blueprint currentUserId]) {
        block(nil);
    } else {
        [BPUser registerWithFacebookId:facebook_id facebookToken:facebook_token email:email name:name withBlock:^(BOOL success, NSError *error) {
            block(error);
        }];
    }
}

+(void)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
                    andBlock:(void(^)(NSError *error, NSDictionary *data))block;
{
    [BPUser authenticateWithEmail:email password:password andBlock:block];
}

+(void)authenticateWithFacebookId:(NSString *)facebook_id
                   facebookToken:(NSString *)facebook_token
                         andBlock:(void(^)(NSError *error, NSDictionary *data))block;
{
    [BPUser authenticateWithFacebookId:facebook_id facebookToken:facebook_token andBlock:block];
}


+(void)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken
                     andBlock:(void (^)(NSError *, NSDictionary *))block
{
    [BPUser authenticateWithUserId:user_id
                     transferToken:transferToken
                          andBlock:block];
}

+(void)destroyCurrentUserWithBlock:(void(^)(NSError *error))block
{
    BPUser *user = [BPUser new];
    user.objectId = [Blueprint currentUserId];
    [user destroyUserWithBlock:^(NSError *error) {
        [self destroySession];
        block(nil);
    }];
}

+(void)updateUserEmail:(NSString *)email withBlock:(void(^)(NSError *error))block
{
    BPUser *user = [BPUser new];
    user.objectId = [Blueprint currentUserId];
    [user updateWithData:@{@"email":email} andBlock:^(NSError *error) {block(error);}];
}

+(void)updateUserPassword:(NSString *)password currentPassword:(NSString *)current_password withBlock:(void(^)(NSError *error))block
{
    BPUser *user = [BPUser new];
    user.objectId = [Blueprint currentUserId];
    [user updateWithData:@{@"password":password, @"current_password": current_password} andBlock:^(NSError *error) {block(error);}];
}


#pragma mark - BPSession

+(BOOL)restoreSession
{
    return [BPSession restoreSession];
}

+(NSString *)currentUserId
{
    return [BPSession user_id];
}

+(void)destroySession
{
    cachedProfile = nil;
    loadingProfile = NO;
    [BPSession destroySession];
}

#pragma mark - BPProfile
+(void)getProfileForUserWithId:(NSString *)user_id withBlock:(void (^)(NSError *, BPProfile *))block
{
    [[Blueprint profileClass] getProfileForUserWithId:user_id withBlock:block];
}

+(void)getCurrentUserProfileWithBlock:(void(^)(NSError *, BPProfile *))block
{
    if(cachedProfile) {
        block(nil, cachedProfile);
    } else if(loadingProfile) {
        if(profileLoadObservers == nil) {
            profileLoadObservers = @[].mutableCopy;
        }
        @synchronized(profileLoadObservers) {
            [profileLoadObservers addObject:block];
        }
    } else {
        [self reloadCurrentUserProfileWithBlock:block];
    }
}

+(void)reloadCurrentUserProfileWithBlock:(void(^)(NSError *, BPProfile *))block
{
    if([self currentUserId]) {
        loadingProfile = YES;
        [[Blueprint profileClass] getProfileForUserWithId:[self currentUserId] withBlock:^(NSError *error, BPProfile *profile) {
        
            if(profile == nil) {
                profile = [[Blueprint profileClass] new];
                [profile addReadGroup:[Blueprint publicGroup]];
                [profile addReadGroup:[Blueprint privateGroup]];
                [profile addDestroyGroup:[Blueprint privateGroup]];
                [profile addWriteGroup:[Blueprint privateGroup]];
            }
            cachedProfile = profile;
            
            block(error, profile);
            loadingProfile = NO;
            
            if(profileLoadObservers) {
                @synchronized(profileLoadObservers) {
                    for(id block in profileLoadObservers) {
                        ((void(^)(NSError *, BPProfile *))block)(nil, cachedProfile);
                    }
                    
                    profileLoadObservers = @[].mutableCopy;
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BPUpdateProfile" object:nil];
        }];
    }
}

+(BPProfile *)cachedProfile
{
    return cachedProfile;
}

#pragma mark - BPGroup

+(BPGroup *)publicGroup
{
    return [BPGroup groupWithId:[BPConfig public_group_id]];
}

+(BPGroup *)privateGroup
{
    return [BPGroup groupWithId:[BPSession user_id]];
}

#pragma mark - Handle Error
+(void)setErrorHandler:(errorBlock)block
{
    [BPError setErrorHandler:block];
}

#pragma mark - Bulk Requests
+(void)enableBulkRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time
{
    [BPApi enableBulkRequestsWithIdleTime:idle_time andMaxCollectionTime:max_collection_time];
}

+(void)runBulkRequests
{
    [BPApi runBulkRequests];
}

+(void)disableBulkRequests
{
    [BPApi disableBulkRequests];
}


@end