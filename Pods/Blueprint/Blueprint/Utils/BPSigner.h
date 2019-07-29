//
//  BPSigner.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPSigner : NSObject

+(NSString *)signString:(NSString *)string withKey:(NSString *)key;

@end
