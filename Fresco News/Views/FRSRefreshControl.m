//
//  FRSRefreshControl.m
//  Fresco
//
//  Created by Nicolas Rizk on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSRefreshControl.h"
#import "UIColor+Additions.h"

@implementation FRSRefreshControl

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.alpha = .54;
        [self setTintColor:[UIColor textHeaderBlackColor]];
    }
    return self;
}

@end
