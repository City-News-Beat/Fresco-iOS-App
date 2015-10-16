//
//  UIView+Border.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addBorderWithWidth:(CGFloat)width{

    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, width / 2, CGRectGetHeight(self.frame));
    leftBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame =CGRectMake([[UIScreen mainScreen] bounds].size.width, 0.0f, width / 2, CGRectGetHeight(self.frame));
    rightBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height, [[UIScreen mainScreen] bounds].size.width, width);
    bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, width);
    topBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    [self.layer addSublayer:rightBorder];
    [self.layer addSublayer:topBorder];
    [self.layer addSublayer:bottomBorder];
    [self.layer addSublayer:leftBorder];
    
}

@end
