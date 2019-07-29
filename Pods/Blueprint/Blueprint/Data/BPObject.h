//
//  BPObject.h
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 5/30/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 
 
Needs to implement sublcassing protocol 
*/

@interface BPObject : NSMutableDictionary

@property (nonatomic, retain) NSString *endpoint_name;
@property (nonatomic, retain) NSString *objectId;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *toDictionary;

@end
