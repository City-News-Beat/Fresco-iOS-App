//
//  UILabel+Custom.m
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "UILabel+Custom.h"

@implementation UILabel (Custom)

+(UILabel *)labelWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = textColor;
    label.font = font;
    return label;
}

@end
