//
//  BPProfile.h
//  Pongtopia
//
//  Created by Hunter on 6/7/15.
//  Copyright (c) 2015 Uberpong. All rights reserved.
//

#import "BPModel.h"

@interface BPProfile : BPModel

+(void)getProfileForUserWithId:(NSString *)user_id
                     withBlock:(void(^)(NSError *error, BPProfile *profile))block;

@end
