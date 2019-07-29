//
//  BPFile.h
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 5/30/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPObject.h"

@interface BPFile : BPObject

@property (strong) NSNumber *size;
@property (strong) NSString *name;


-(instancetype)initWithRecord:(BPObject *)record data:(NSData *)data andName:(NSString *)name;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary andRecord:(BPObject *)record;

-(void)uploadWithBlock:(void (^)(NSError *error))completionBlock;
-(void)destroyWithBlock:(void (^)(NSError *error))completionBlock;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *downloadURL;
@end
