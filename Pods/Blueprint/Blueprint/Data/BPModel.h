//
//  BPModel.h
//  Blueprint-Cocoa
//
//  Created by Hunter Dolan on 6/3/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPRecord.h"

#import "BPMultiRecordPromise.h"
#import "BPSingleRecordPromise.h"

@interface BPModel : BPRecord

typedef void (^BPSingleRecordResponseBlock)(NSError * _Nullable error, BPRecord * _Nullable record);
typedef void (^BPMultiRecordResponseBlock)(NSError * _Nullable error, NSArray<BPRecord*> * _Nullable records);

+(NSString * _Nonnull)endpointName;

- (instancetype _Nonnull)init:(NSDictionary * _Nonnull)dictionary;

// Block Based
+ (void)find:(NSDictionary<NSString*, NSObject*> * _Nonnull)where
   withBlock:(BPMultiRecordResponseBlock _Nonnull)block;

+ (void)where:(NSDictionary<NSString*, NSObject*> * _Nonnull)where
    withBlock:(BPMultiRecordResponseBlock _Nonnull)block;

+ (void)findById:(NSString * _Nonnull)_id
       withBlock:(BPSingleRecordResponseBlock _Nonnull)block;

+ (void)findOne:(NSDictionary<NSString*, NSObject*> * _Nonnull)where
      withBlock:(BPSingleRecordResponseBlock _Nonnull)block;

// Promise Based
+ (BPMultiRecordPromise * _Nonnull)find:(NSDictionary<NSString*, NSObject*> * _Nonnull)where;
+ (BPSingleRecordPromise * _Nonnull)findById:(NSString * _Nonnull)_id;
+ (BPSingleRecordPromise * _Nonnull)findOne:(NSDictionary<NSString*, NSObject*> * _Nonnull)where;

// Record
+(instancetype _Nonnull)recordWithContent:(NSDictionary<NSString*, NSObject*> * _Nonnull)content;

@end
