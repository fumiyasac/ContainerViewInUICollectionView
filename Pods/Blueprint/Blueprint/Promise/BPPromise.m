//
//  BPPromise.m
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPPromise.h"

@interface BPPromise()
@property (strong) NSMutableArray<BPPromiseSuccessBlock>* successBlocks;
@property (strong) NSMutableArray<BPPromiseFailBlock>* failBlocks;

@property BOOL completed;

@property (strong) NSError *error;

@end


@implementation BPPromise

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.successBlocks = [[NSMutableArray alloc] init];
        self.failBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(BPPromise *)then:(BPPromiseSuccessBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(!_error) {
                block();
            }
        } else {
            [_successBlocks addObject:block];
        }
    }
    
    return self;
}

-(BPPromise *)fail:(BPPromiseFailBlock)block
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

-(void)completeWithError:(NSError * _Nullable)error
{
    @synchronized (self) {
        if(!_completed) {
            _completed = YES;
            
            _error = error;
            
            if(_error) {
                for(BPPromiseFailBlock block in _failBlocks) {
                    block(_error);
                }
            } else {
                for(BPPromiseSuccessBlock block in _successBlocks) {
                    block();
                }
            }
        }
    }
}

@end
