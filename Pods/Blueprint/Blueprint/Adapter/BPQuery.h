//
//  BPQuery.h
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 6/1/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPRecord.h"

@interface BPQuery : NSObject

@property (nonatomic, strong, readonly) NSString *endpoint;

+ (BPQuery *)queryForEndpoint:(NSString *)name;
- (void)findRecordsWhere:(NSDictionary *)where withBlock:(void (^)(NSError *error, NSArray *objects))completionBlock;
- (void)findDataWhere:(NSDictionary *)where withBlock:(void (^)(NSError *error, NSArray *objects))completionBlock;

@end
