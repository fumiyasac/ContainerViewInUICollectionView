//
//  BPMultiRecordPromise.m
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPMultiRecordPromise.h"

@interface BPMultiRecordPromise()
@property (strong) NSMutableArray<BPMultiRecordSuccessBlock>* successBlocks;
@property (strong) NSMutableArray<BPMultiRecordFailBlock>* failBlocks;

@property BOOL completed;

@property (strong) NSArray<BPRecord *> *records;
@property (strong) NSError *error;

@end

@implementation BPMultiRecordPromise

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.successBlocks = [[NSMutableArray alloc] init];
        self.failBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(BPMultiRecordPromise *)then:(BPMultiRecordSuccessBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(_records) {
                block(_records);
            }
        } else {
            [_successBlocks addObject:block];
        }
    }
    
    return self;
}

-(BPMultiRecordPromise *)fail:(BPMultiRecordFailBlock)block
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

-(void)completeWith:(NSArray<BPRecord *> * _Nullable)records andError:(NSError * _Nullable)error
{
    @synchronized (self) {
        if(!_completed) {
            _completed = YES;
            
            _records = records;
            _error = error;
            
            if(_error) {
                for(BPMultiRecordFailBlock block in _failBlocks) {
                    block(_error);
                }
            } else if(_records) {
                for(BPMultiRecordSuccessBlock block in _successBlocks) {
                    block(_records);
                }
            }
        }
    }
}

@end