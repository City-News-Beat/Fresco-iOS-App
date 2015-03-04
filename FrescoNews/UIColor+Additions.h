//
//  UIColor+Additions.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/3/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FBBHexColor(component) (((CGFloat)(component)) / (CGFloat)0xff)

@interface UIColor (Additions)
+ (instancetype)colorWithHex:(NSString *)hex;
+ (instancetype)colorWithHex:(NSString *)hex alpha:(float)alpha;

+(instancetype)colorWithHexInteger:(uint32_t)hex;

+(instancetype)userTeamNameTextColor;
+(instancetype)otherTeamNameTextColor;

+(UIColor *)lighterColorForColor:(UIColor *)c byDegree:(float)degree;
+(UIColor *)darkerColorForColor:(UIColor *)c byDegree:(float)degree;

+(UIColor *)gdlColorDarkGray;
+(UIColor *)tileBorderColor;
+(UIColor *)tileBorderColorLive;

+ (CGFloat)componentFromColorString:(NSString *)colorString colorName:(NSString *)colorName;

@end
