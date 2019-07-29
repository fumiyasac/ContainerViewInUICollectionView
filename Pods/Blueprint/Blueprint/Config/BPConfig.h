//
//  BPConfig.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPConfig : NSObject

+(NSString *)protocol;
+(NSString *)port;
+(NSString *)host;
+(NSString *)application_id;
+(NSString *)public_group_id;

@property (strong) NSDictionary *data;

+(NSObject *)objectForKey:(NSString *)key;
+(void)setConfig:(NSDictionary *)config_dictionary;
@end
