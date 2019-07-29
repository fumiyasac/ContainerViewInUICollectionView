//
//  BPPromise.h
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPPromise : NSObject

typedef void (^BPPromiseSuccessBlock)();
typedef void (^BPPromiseFailBlock)(NSError* _Nonnull error);

-(BPPromise * _Nonnull)then:(BPPromiseSuccessBlock _Nonnull)block;
-(BPPromise * _Nonnull)fail:(BPPromiseFailBlock _Nonnull)block;

@end
