//
//  BPMultiRecordPromise.h
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPRecord.h"

@interface BPMultiRecordPromise : NSObject

typedef void (^BPMultiRecordSuccessBlock)(NSArray<BPRecord *> * _Nonnull record);
typedef void (^BPMultiRecordFailBlock)(NSError* _Nonnull error);

-(BPMultiRecordPromise * _Nonnull)then:(BPMultiRecordSuccessBlock _Nonnull)block;
-(BPMultiRecordPromise * _Nonnull)fail:(BPMultiRecordFailBlock _Nonnull)block;

@end
