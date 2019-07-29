//
//  BPError.m
//  Toga
//
//  Created by Hunter on 7/10/15.
//  Copyright (c) 2015 Greeklink. All rights reserved.
//

#import "BPError.h"

@implementation BPError

static errorBlock handler;

+(BOOL)handleError:(NSError *)error
{
    if(handler) {
        return handler(error);
    } else {
        return YES;
    }
}

+(void)setErrorHandler:(errorBlock)block
{
    handler = block;
}

@end
