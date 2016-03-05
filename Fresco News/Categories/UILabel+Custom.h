//
//  UILabel+Custom.h
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Custom)

+(UILabel *)labelWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font;
-(void)enableDropShadow:(BOOL)shouldShadow;
@end
