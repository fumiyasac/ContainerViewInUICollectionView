//
//  BPModel.m
//  Blueprint-Cocoa
//
//  Created by Hunter Dolan on 6/3/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPModel.h"
#import "BPQuery.h"

#import "BPPromise+PrivateHeaders.h"

@interface BPModel()

@property (nonatomic, retain) NSMutableDictionary *permissions;

@end

@implementation BPModel

@dynamic permissions;

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.endpoint_name = [[self class] endpointName];
    }
    return self;
}

-(instancetype)init:(NSDictionary *)dictionary
{
    self = [self init];
    if(self) {
        self.endpoint_name = [[self class] endpointName];
        self.content = dictionary.mutableCopy;
    }
    
    return self;
}

+(id)new
{
    return [[[self class] alloc] init];
}

+(NSString *)endpointName
{
    NSString *name = [NSString stringWithFormat:@"%@s", NSStringFromClass([self class])].lowercaseString;
    return [name componentsSeparatedByString:@"."].lastObject;
}

+ (void)find:(NSDictionary<NSString*, NSObject*> *)where withBlock:(BPMultiRecordResponseBlock)block;
{
    [self where:where withBlock:block];
}

+(void)where:(NSDictionary<NSString*, NSObject*> *)where withBlock:(BPMultiRecordResponseBlock)block
{
    BPQuery *query = [BPQuery queryForEndpoint:[[self class] endpointName]];
    [query findDataWhere:where withBlock:^(NSError *error, NSArray *objects) {
        NSMutableArray *records = @[].mutableCopy;
        if(!error) {
            for(NSDictionary *content in objects) {
                [records addObject:[[self class] recordWithContent:content]];
            }
        }
        
        block(error, records);
    }];
}

+(void)findById:(NSString *)_id withBlock:(BPSingleRecordResponseBlock)block
{
    [[self class] where:@{@"id":_id, @"$limit": @1} withBlock:^(NSError *error, NSArray *records) {
        BPRecord *record;
        if(error) {
            
        } else if(records.count == 0) {
            error = [NSError errorWithDomain:@"org.blueprint.error" code:404 userInfo:@{}];
        } else {
            record = records[0];
        }
        
        block(error, record);
    }];
}

+ (void)findOne:(NSDictionary<NSString*, NSObject*> *)where withBlock:(BPSingleRecordResponseBlock)block
{
    NSMutableDictionary *query = where.mutableCopy;
    query[@"$limit"] = @1;
    
    [[self class] where:query withBlock:^(NSError *error, NSArray *records) {
        BPRecord *record;
        if(error) {
            
        } else if(records.count == 0) {
            error = [NSError errorWithDomain:@"org.blueprint.error" code:404 userInfo:@{}];
        } else {
            record = records[0];
        }
        
        block(error, record);
    }];
}

+(id)recordWithContent:(NSDictionary *)content
{
    return [[self class] recordWithEndpointName:[[self class] endpointName] andContent:content];
}

//
// Promise
//

+ (BPMultiRecordPromise * _Nonnull)find:(NSDictionary<NSString*, NSObject*> * _Nonnull)where
{
    BPMultiRecordPromise *promise = [BPMultiRecordPromise new];
    
    [self find:where withBlock:^(NSError * _Nullable error, NSArray<BPRecord *> * _Nullable records) {
        [promise completeWith:records andError:error];
    }];
    
    return promise;
}

+ (BPSingleRecordPromise * _Nonnull)findById:(NSString * _Nonnull)_id
{
    BPSingleRecordPromise *promise = [BPSingleRecordPromise new];
    
    [self findById:_id withBlock:^(NSError * _Nullable error, BPRecord * _Nullable record) {
        [promise completeWith:record andError:error];
    }];
    
    return promise;
}

+ (BPSingleRecordPromise * _Nonnull)findOne:(NSDictionary<NSString*, NSObject*> * _Nonnull)where
{
    BPSingleRecordPromise *promise = [BPSingleRecordPromise new];
    
    [self findOne:where withBlock:^(NSError * _Nullable error, BPRecord * _Nullable record) {
        [promise completeWith:record andError:error];
    }];
    
    return promise;
}


@end
