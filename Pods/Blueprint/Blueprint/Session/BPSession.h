//
//  BPSession.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPSession : NSObject
@property (strong) NSDictionary *data;



+(BPSession *)sharedSession;
+(NSObject *)objectForKey:(NSString *)key;

+(BOOL)restoreSession;
+(void)destroySession;

+(NSString *)auth_token;
+(NSString *)user_id;
+(NSString *)session_id;

-(void)setSession:(NSDictionary *)session;
@property (NS_NONATOMIC_IOSONLY, getter=isSessionActive, readonly) BOOL sessionActive;

@end
