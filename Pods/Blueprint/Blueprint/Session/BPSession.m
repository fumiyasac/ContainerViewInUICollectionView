//
//  BPSession.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPSession.h"

@implementation BPSession

static BPSession *bp_shared_session = nil;

+(BPSession *)sharedSession
{
    if(bp_shared_session == nil) {
        bp_shared_session = [[BPSession alloc] init];
    }
    
    return bp_shared_session;
}

+(NSObject *)objectForKey:(NSString *)key
{
    return [[BPSession sharedSession] objectForKey:key];
}

+(NSString *)auth_token
{
    return (NSString *)[BPSession objectForKey:@"auth_token"];
}

+(NSString *)user_id
{
    return (NSString *)[BPSession objectForKey:@"user_id"];
}

+(NSString *)session_id
{
    return (NSString *)[BPSession objectForKey:@"session_id"];
}


+(BOOL)restoreSession
{
    BPSession *session = [BPSession sharedSession];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *blueprint_session = [userDefaults objectForKey:@"blueprint_session"];
    if(blueprint_session) {
        [session setSession:blueprint_session];
        
        if([BPSession auth_token] && [BPSession user_id] && [BPSession session_id]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+(void)destroySession
{
    [BPSession sharedSession].data = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@{} forKey:@"blueprint_session"];
    [userDefaults synchronize];
}

// Instance Methods

-(NSObject *)objectForKey:(NSString *)key
{
    return self.data[key];
}

-(void)setSession:(NSDictionary *)session
{
    self.data = session;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:session forKey:@"blueprint_session"];
    [userDefaults synchronize];
}

-(BOOL)isSessionActive
{
    return self.data ? YES : NO;
}


@end
