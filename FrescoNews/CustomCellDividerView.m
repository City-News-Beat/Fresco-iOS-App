//
//  CustomCellDividerView.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CustomCellDividerView.h"

@implementation CustomCellDividerView

-(void)layoutSubviews {
    [super layoutSubviews];
    if([self.constraints count] == 0) {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        if(width == 1) {
            width = width / [UIScreen mainScreen].scale;
        }
        if (height == 0) {
            height = 1 / [UIScreen mainScreen].scale;
        }
        
        if(height == 1) {
            height = height / [UIScreen mainScreen].scale;
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    }
    else {
        for(NSLayoutConstraint *constraint in self.constraints) {
            if((constraint.firstAttribute == NSLayoutAttributeWidth || constraint.firstAttribute == NSLayoutAttributeHeight) && constraint.constant == 1) {
                constraint.constant /=[UIScreen mainScreen].scale;
            }
        }
    }
}

@end
