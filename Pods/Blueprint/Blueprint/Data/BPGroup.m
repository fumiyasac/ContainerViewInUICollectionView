//
//  SFGroup.m
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPGroup.h"
#import "BPApi.h"


@interface BPGroup()
@property (nonatomic, retain) NSMutableDictionary *permissions;
@property (nonatomic, retain) NSMutableDictionary *groupContent;
@end

@implementation BPGroup

-(instancetype)init
{
    self = [super init];
    
    self.permissions = @{}.mutableCopy;
    self.groupContent = @{}.mutableCopy;

    return self;
}

+(BPGroup *)groupWithId:(NSString *)objectId
{
    BPGroup *group = [[BPGroup alloc] init];
    group.objectId = objectId;
    
    return group;
}

- (void)saveWithBlock:(void (^)(NSError *))completionBlock
{
    NSDictionary *request = @{@"group": self.groupContent, @"permissions": self.permissions};

    if(self.objectId) {
        [BPApi put:[NSString stringWithFormat:@"%@/%@", @"groups", self.objectId] withData:request andBlock:^(NSError *error, id responseObject) {
            [self handleResponseObject:responseObject];
            completionBlock(error);
        }];
    } else {
        [BPApi post:@"groups" withData:request andBlock:^(NSError *error, id responseObject) {
            [self handleResponseObject:responseObject];
            completionBlock(error);
        }];
    }
}

-(void)handleResponseObject:(NSDictionary *)responseObject
{
    NSDictionary *data = (NSDictionary *)responseObject[@"response"][@"groups"][0];
    self.objectId = data[@"id"];
    self.permissions = [data[@"permissions"] mutableCopy];
    self.groupContent = data.mutableCopy;
}

-(NSString *)description
{
    return self.groupContent.description;
}

#pragma mark - Getters

-(NSString *)name
{
    return self.groupContent[@"name"];
}

-(BOOL)open
{
    return [self.groupContent[@"open"] boolValue];
}

-(BOOL)permissive
{
    return [self.groupContent[@"permissive"] boolValue];
}

#pragma mark - Setters

-(void)setName:(NSString *)name
{
    self.groupContent[@"name"] = name;
}

-(void)setOpen:(BOOL)open
{
    self.groupContent[@"open"] = @(open);
}

-(void)setPermissive:(BOOL)permissive
{
    self.groupContent[@"permissive"] = @(permissive);
}

-(void)setPassword:(NSString *)password
{
    self.groupContent[@"password"] = password;
}

#pragma mark - User Management

-(void)addId:(NSString *)_id toKey:(NSString *)key andInverse:(NSString *)inverse
{
    if(self.groupContent[key] == nil) {
        self.groupContent[key] = @[].mutableCopy;
    }
    
    if([self.groupContent[key] indexOfObject:_id] == NSNotFound) {
        [self.groupContent[key] addObject:_id];
    }
    
    if(self.groupContent[inverse] != nil && [self.groupContent[inverse] indexOfObject:_id] != NSNotFound) {
        [self.groupContent[inverse] removeObject:_id];
    }
}

-(void)addUser:(BPUser *)user
{
    [self addId:user.objectId toKey:@"add_user_ids" andInverse:@"remove_user_ids"];
}

-(void)addSuperUser:(BPUser *)user
{
    [self addId:user.objectId toKey:@"add_super_user_ids" andInverse:@"remove_super_user_ids"];
}

-(void)removeUser:(BPUser *)user
{
    [self addId:user.objectId toKey:@"remove_user_ids" andInverse:@"add_user_ids"];
}

-(void)removeSuperUser:(BPUser *)user
{
    [self addId:user.objectId toKey:@"remove_super_user_ids" andInverse:@"add_super_user_ids"];
}

#pragma mark - Joining

-(void)joinGroupWithPassword:(NSString *)password andBlock:(void (^)(NSError *))completionBlock
{
    NSMutableDictionary *group = @{}.mutableCopy;
    
    if(password != nil) {
        group[@"password"] = password;
    }
    
    NSDictionary *request = @{@"group": group};
    
    NSString *url = [NSString stringWithFormat:@"groups/%@/join", self.objectId];
    
    [BPApi post:url withData:request andBlock:^(NSError *error, id responseObject) {
        if(responseObject[@"response"][@"groups"] == nil) {
            error = [NSError errorWithDomain:@"co.goblueprint.error" code:403 userInfo:nil];
        }
        
        completionBlock(error);
    }];
}

-(void)joinGroupWithBlock:(void (^)(NSError *))completionBlock
{
    [self joinGroupWithPassword:nil andBlock:completionBlock];
}

@end
