//
//  FRSUserStoryManager.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryManager.h"

@implementation FRSUserStoryManager

+ (instancetype)sharedInstance {
    static FRSUserStoryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FRSUserStoryManager alloc] init];
    });
    return instance;
}

@end
