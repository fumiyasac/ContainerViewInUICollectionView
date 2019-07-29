//
//  BPError.h
//  Toga
//
//  Created by Hunter on 7/10/15.
//  Copyright (c) 2015 Greeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPError : NSObject

typedef BOOL (^errorBlock)(NSError *error);

+(BOOL)handleError:(NSError *)error;
+(void)setErrorHandler:(errorBlock)block;

@end
