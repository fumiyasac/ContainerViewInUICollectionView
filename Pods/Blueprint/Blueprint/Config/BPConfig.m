//
//  BPConfig.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPConfig.h"
#import "BPConstants.h"

@implementation BPConfig

static BPConfig *bp_shared_config = nil;

+(BPConfig *)sharedConfig
{
    if(bp_shared_config == nil) {
        bp_shared_config = [[BPConfig alloc] init];
    }
    
    return bp_shared_config;
}

+(void)setConfig:(NSDictionary *)config_dictionary
{
    NSMutableDictionary *base_config = @{
        @"host": blueprint_default_host,
        @"protocol": blueprint_default_protocol,
        @"port": @(blueprint_default_port),
        @"application_id": blueprint_default_application_id
    }.mutableCopy;
    
    BPConfig *config = [BPConfig sharedConfig];
    
    for(NSString *key in config_dictionary) {
        base_config[key] = config_dictionary[key];
    }
    
    [config setConfig:base_config];
}

+(NSObject *)objectForKey:(NSString *)key
{
    return [[BPConfig sharedConfig] objectForKey:key];
}


// Helper Methods
+(NSString *)protocol
{
    return (NSString *)[BPConfig objectForKey:@"protocol"];
}

+(NSString *)port
{
    return (NSString *)[BPConfig objectForKey:@"port"];
}

+(NSString *)host
{
    return (NSString *)[BPConfig objectForKey:@"host"];
}

+(NSString *)application_id
{
    return (NSString *)[BPConfig objectForKey:@"application_id"];
}

+(NSString *)public_group_id
{
    if([BPConfig objectForKey:@"public_group_id"]) {
        return (NSString *)[BPConfig objectForKey:@"public_group_id"];
    } else {
        return [self application_id];
    }
}

// Instance Methods

-(NSObject *)objectForKey:(NSString *)key
{
    return self.data[key];
}

-(void)setConfig:(NSDictionary *)config
{
    self.data = config;
}

@end
