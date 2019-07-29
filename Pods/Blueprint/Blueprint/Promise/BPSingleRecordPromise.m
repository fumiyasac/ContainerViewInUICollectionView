//
//  BPSingleRecordPromise.m
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPSingleRecordPromise.h"

@interface BPSingleRecordPromise()
@property (strong) NSMutableArray<BPSingleRecordSuccessBlock>* successBlocks;
@property (strong) NSMutableArray<BPSingleRecordFailBlock>* failBlocks;

@property BOOL completed;

@property (strong) BPRecord *record;
@property (strong) BPError *error;

@end

@implementation BPSingleRecordPromise

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.successBlocks = [[NSMutableArray alloc] init];
        self.failBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(BPSingleRecordPromise *)then:(BPSingleRecordSuccessBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(_record) {
                block(_record);
            }
        } else {
            [_successBlocks addObject:block];
        }
    }
    
    return self;
}

-(BPSingleRecordPromise *)fail:(BPSingleRecordFailBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(_error) {
                block(_error);
            }
        } else {
            [_failBlocks addObject:block];
        }
    }
    
    return self;
}

-(void)completeWith:(BPRecord * _Nullable)record andError:(BPError * _Nullable)error
{
    @synchronized (self) {
        if(!_completed) {
            _completed = YES;

            _record = record;
            _error = error;
            
            if(_error) {
                for(BPSingleRecordFailBlock block in _failBlocks) {
                    block(_error);
                }
            } else if(_record) {
                for(BPSingleRecordSuccessBlock block in _successBlocks) {
                    block(_record);
                }
            }
        }
    }
}

@end
