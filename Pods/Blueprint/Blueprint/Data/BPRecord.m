//
//  SFRecord.m
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPRecord.h"
#import "BPApi.h"
#import "BPProfile.h"

#import "BPPromise+PrivateHeaders.h"

@interface BPRecord()
@end

@implementation BPRecord

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.content = [[NSMutableDictionary alloc] init];
        self.files = @{}.mutableCopy;
        self.permissions = @{}.mutableCopy;
        self.permissions[@"read_group_ids"] = @[].mutableCopy;
        self.permissions[@"write_group_ids"] = @[].mutableCopy;
        self.permissions[@"destroy_group_ids"] = @[].mutableCopy;
    }
    
    return self;
}

+ (instancetype)recordWithEndpointName:(NSString *)name
{
    BPRecord *record = [[[self class] alloc] init];
    record.endpoint_name = name;
    return record;
}

+ (instancetype)recordWithEndpointName:(NSString *)name andContent:(NSDictionary *)content
{
    BPRecord *record = [[self class] recordWithEndpointName:name];
    record.objectId = content[@"id"];
    record.permissions = [content[@"permissions"] mutableCopy];
    record.content = [content[@"content"] mutableCopy];
    record.createdAtNumber = content[@"created_at"];
    record.updatedAtNumber = content[@"updated_at"];
    record.createdById = content[@"created_by"];
    [record setFilesArray: content[@"files"]];
    
    record.canWrite = [@1 isEqual:content[@"capabilities"][@"write"]];
    record.canDestroy = [@1 isEqual:content[@"capabilities"][@"destroy"]];
    
    return record;
}

-(void)setFilesArray:(NSArray *)files
{
    if(files) {
        for(NSDictionary *file_data in files) {
            BPFile *file = [[BPFile alloc] initWithDictionary:file_data andRecord:self];
            
            self.files[file.name] = file;
        }
    }
}


- (void)saveWithBlock:(void (^)(NSError *))completionBlock
{
    if (self.permissions == nil) {
        self.permissions = @{
                             @"read_group_ids":@[].mutableCopy,
                             @"write_group_ids":@[].mutableCopy,
                             @"destroy_group_ids":@[].mutableCopy
        }.mutableCopy;
        
    }

    if(self.content) {
        NSDictionary *request = @{@"content": self.content, @"permissions": self.permissions};
        
        if(self.objectId) {
            [BPApi put:[NSString stringWithFormat:@"%@/%@", self.endpoint_name, self.objectId] withData:request andBlock:^(NSError *error, id responseObject) {
                [self handleResponseObject:responseObject];
                completionBlock(error);
            }];
        } else {
            [BPApi post:self.endpoint_name withData:request andBlock:^(NSError *error, id responseObject) {
                [self handleResponseObject:responseObject];
                completionBlock(error);
            }];
        }
    } else {
        completionBlock([NSError errorWithDomain:@"co.goblueprint.error" code:0001 userInfo:nil]);
    }
}

- (void)saveAsUnauthenticatedUserWithBlock:(void (^)(NSError *))completionBlock
{
    NSDictionary *request = @{@"content": self.content, @"permissions": self.permissions};
    
    if(self.objectId) {
        [BPApi put:[NSString stringWithFormat:@"%@/%@", self.endpoint_name, self.objectId]
          withData:request
     authenticated:NO
          andBlock:^(NSError *error, id responseObject) {
            [self handleResponseObject:responseObject];
            completionBlock(error);
        }];
    } else {
        [BPApi post:self.endpoint_name
           withData:request
      authenticated:NO
           andBlock:^(NSError *error, id responseObject) {
            [self handleResponseObject:responseObject];
            completionBlock(error);
        }];
    }
}

- (BPPromise *)save
{
    BPPromise *promise = [BPPromise new];
    
    [self saveWithBlock:^(NSError *error) {
        [promise completeWithError:error];
    }];
    
    return promise;
}

-(void)handleResponseObject:(NSDictionary *)responseObject
{
    NSDictionary *data = (NSDictionary *)responseObject[@"response"][self.endpoint_name][0];
    self.objectId = data[@"id"];
    self.permissions = [data[@"permissions"] mutableCopy];
    self.content = [data[@"content"] mutableCopy];
}

- (void)destroyRecordWithBlock:(void (^)(NSError *error))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/%@/destroy", self.endpoint_name, self.objectId];
    [BPApi post:url withData:@{} andBlock:^(NSError *error, id responseObject) {
        completionBlock(error);
    }];
}

#pragma mark - Data

-(void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if(obj == nil || key == nil) {
        return;
    }

    self.content[(NSString *)key] = obj;
}

-(void)setObject:(id)object forKey:(NSString *)key
{
    if(object == nil) {
        [self removeObjectForKey:key];
        return;
    } else if (key == nil) {
        return;
    }
    
    NSString *capitalized_key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                             withString:[key substringToIndex:1].capitalizedString];
    
    NSString *select_string = [NSString stringWithFormat:@"overrideSet%@:", capitalized_key];
    SEL setSelector = NSSelectorFromString(select_string);

    if([self respondsToSelector:setSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:setSelector withObject:object];
#pragma pop
    } else {
        // Add the object to the content
        (self.content)[key] = object;
    }
}

- (id)objectForKey:(NSString *)key
{
    id obj = (self.content)[key];
    return obj;
}

-(void)removeObjectForKey:(id)aKey
{
    [self.content removeObjectForKey:aKey];
    [self.content removeObjectForKey:[NSString stringWithFormat:@"%@_ids", aKey]];
}

#pragma mark - Meta Helpers

-(NSDate *)createdAt
{
    return [NSDate dateWithTimeIntervalSince1970:(self.createdAtNumber).integerValue];
}

-(NSDate *)updatedAt
{
    return [NSDate dateWithTimeIntervalSince1970:(self.updatedAtNumber).integerValue];
}

#pragma mark - Permissions

// Setters

- (void)setGroups:(NSDictionary *)permissions{
    (self.permissions)[@"destroy_group_ids"] = permissions[@"destroy_group_ids"];
    (self.permissions)[@"read_group_ids"] = permissions[@"read_group_ids"];
    (self.permissions)[@"write_group_ids"] = permissions[@"write_group_ids"];
}

-(void)setGroups:(NSArray *)array forType:(NSString *)type
{
    NSString *key = [NSString stringWithFormat:@"%@_group_ids", type];
    (self.permissions)[key] = [self cleanGroupArray:array];
}

- (void)setReadGroups:(NSArray *)readGroups
{
    [self setGroups:readGroups forType:@"read"];
}

- (void)setWriteGroups:(NSArray *)writeGroups
{
    [self setGroups:writeGroups forType:@"write"];
}

- (void)setDestroyGroups:(NSArray *)destroyGroups
{
    [self setGroups:destroyGroups forType:@"destroy"];
}

// Appenders

-(void)appendGroup:(BPGroup *)group forType:(NSString *)type
{
    NSString *key = [NSString stringWithFormat:@"%@_group_ids", type];
    NSArray *groups = (self.permissions)[key];

    if(groups == nil) {
        groups = @[];
    }
    
    NSMutableArray *mutable_groups = groups.mutableCopy;
    [mutable_groups addObject:[self cleanGroupObject:group]];
    
    [self setGroups:mutable_groups forType:type];
}

-(void)addReadGroup:(BPGroup *)group
{
    [self appendGroup:group forType:@"read"];
}

-(void)addWriteGroup:(BPGroup *)group
{
    [self appendGroup:group forType:@"write"];
}

-(void)addDestroyGroup:(BPGroup *)group
{
    [self appendGroup:group forType:@"destroy"];
}

// Removers

-(void)removeGroup:(BPGroup *)group forType:(NSString *)type
{
    NSString *key = [NSString stringWithFormat:@"%@", type];
    NSArray *groups = (self.permissions)[key];
    if(groups == nil) {
        groups = @[];
    }
    
    NSMutableArray *mutable_groups = groups.mutableCopy;
    [mutable_groups removeObject:[self cleanGroupObject:group]];
    
    [self setGroups:mutable_groups forType:key];
}

-(void)removeReadGroup:(BPGroup *)group
{
    [self removeGroup:group forType:@"read"];
}

-(void)removeWriteGroup:(BPGroup *)group
{
    [self removeGroup:group forType:@"write"];
}

-(void)removeDestroyGroup:(BPGroup *)group
{
    [self removeGroup:group forType:@"destroy"];
}

// Helpers

-(NSString *)cleanGroupObject:(NSObject *)group {
    NSString *group_id = (NSString *)group;
    
    if([group isKindOfClass:[BPObject class]]) {
        group_id = ((BPObject *)group).objectId;
    }
    
    return group_id;
}

- (NSArray *)cleanGroupArray:(NSArray *)array
{
    NSMutableArray *new_array = @[].mutableCopy;
    
    for(NSObject *group in array) {
        [new_array addObject:[self cleanGroupObject:group]];
    }
    
    return new_array;
}

#pragma mark Files

-(void)uploadFileWithData:(NSData *)data name:(NSString *)name andBlock:(void(^)(NSError *error, BPFile *file))block
{
    BPFile *file = [[BPFile alloc] initWithRecord:self data:data andName:name];
    
    [file uploadWithBlock:^(NSError *error) {
        self.files[name] = file;
        block(error, file);
    }];
}

-(BPFile *)fileWithName:(NSString *)name
{
    return self.files[name];
}

#pragma mark - Profile

-(void)profileForCreatorWithBlock:(void(^)(NSError *error, BPRecord* profile))block
{
    [BPProfile getProfileForUserWithId:self.createdById withBlock:block];
}

#pragma mark NSDictionary Methods


-(NSArray *)allKeys
{
    return (self.content).allKeys;
}

-(NSUInteger)count
{
    return (self.content).count;
}

-(NSEnumerator *)keyEnumerator
{
    return [self.content keyEnumerator];
}

@end
