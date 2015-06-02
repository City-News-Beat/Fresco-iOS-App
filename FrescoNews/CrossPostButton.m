//
//  CrossPostButton.m
//  FrescoNews
//
//  Created by Joshua C. Lerner on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CrosspostButton.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@implementation CrossPostButton

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [super setSelected:YES];
        self.alpha = 1.0;
    }
    else {
        [super setSelected:NO];
        self.alpha = 0.54;
    }
}

@end
