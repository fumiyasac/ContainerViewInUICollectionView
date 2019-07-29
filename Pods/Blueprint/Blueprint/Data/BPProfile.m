//
//  BPProfile.m
//  Pongtopia
//
//  Created by Hunter on 6/7/15.
//  Copyright (c) 2015 Uberpong. All rights reserved.
//

#import "BPProfile.h"

@implementation BPProfile

+(NSString *)endpointName
{
    return @"profiles";
}

+(void)getProfileForUserWithId:(NSString *)user_id withBlock:(void (^)(NSError *, BPProfile *))block
{
    [[self class] where:@{@"created_by":user_id} withBlock:^(NSError *error, NSArray *records) {
        if(records.count == 0) {
            block(error, nil);
        } else {
            block(error, records[0]);
        }
    }];
}

@end
