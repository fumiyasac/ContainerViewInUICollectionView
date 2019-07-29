//
//  BPApi.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPApi : NSObject
+(void)post:(NSString *)path
   withData:(NSDictionary *)data
   andBlock:(void(^)(NSError *error, id responseObject))block;

+(void)put:(NSString *)path
  withData:(NSDictionary *)data
  andBlock:(void(^)(NSError *error, id responseObject))block;

+(void)post:(NSString *)path
   withData:(NSDictionary *)data
authenticated:(BOOL)authenticated
   andBlock:(void(^)(NSError *error, id responseObject))block;

+(void)put:(NSString *)path
  withData:(NSDictionary *)data
authenticated:(BOOL)authenticated
  andBlock:(void(^)(NSError *error, id responseObject))block;


+(NSURL *)buildURLWithPath:(NSString *)path;

+(void)enableBulkRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time;
+(void)runBulkRequests;
+(void)disableBulkRequests;

@end
