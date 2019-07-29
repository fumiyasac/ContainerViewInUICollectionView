//
//  BPHTTP.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPHTTP : NSObject

+(void)sendRequestWithURL:(NSURL *)url
                   method:(NSString *)method
                     data:(NSDictionary *)data
                 andBlock:(void(^)(NSError *error, id responseObject))block;

@end
