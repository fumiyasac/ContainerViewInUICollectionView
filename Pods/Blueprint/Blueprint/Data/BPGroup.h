//
//  SFGroup.h
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPObject.h"
#import "BPUser.h"

@interface BPGroup : BPObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL open;
@property (nonatomic) BOOL permissive;
@property (strong, nonatomic) NSString *password;

+(BPGroup *)groupWithId:(NSString *)objectId;
- (void)saveWithBlock:(void (^)(NSError *error))completionBlock;

- (void)addUser:(BPUser *)user;
- (void)addSuperUser:(BPUser *)user;
- (void)removeUser:(BPUser *)user;
- (void)removeSuperUser:(BPUser *)user;

-(void)joinGroupWithPassword:(NSString *)password andBlock:(void (^)(NSError *))completionBlock;
-(void)joinGroupWithBlock:(void (^)(NSError *))completionBlock;

@end
