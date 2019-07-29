//
//  BPOrderedDictionary.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPOrderedDictionary.h"

@implementation BPOrderedDictionary

+(BPOrderedDictionary *)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    BPOrderedDictionary *dict = [[BPOrderedDictionary alloc] init];
    dict.keys = keys;
    dict.objects = objects;
    return dict;
}

-(id)objectForKey:(id)aKey
{
    return self.objects[[self.keys indexOfObject:aKey]];
}

-(NSUInteger)count
{
    return self.keys.count;
}

-(NSEnumerator *)keyEnumerator
{
    return [self.keys objectEnumerator];
}

-(NSArray *)allKeys
{
    return self.keys;
}

@end
