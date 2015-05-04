//
//  UIColor+Additions.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/3/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (instancetype)colorWithHex:(NSString *)hex {
    return [self colorWithHex:hex alpha:1.0f];
}

+ (instancetype)colorWithHex:(NSString *)hex alpha:(float)alpha {
	
    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
	
    uint hexInt;
    if ([[NSScanner scannerWithString:hex] scanHexInt:&hexInt]) {
        return [self colorWithRed:(float)((hexInt & 0xFF0000) >> 16) / 255.0f
                            green:(float)((hexInt & 0x00FF00) >>  8) / 255.0f
                             blue:(float)((hexInt & 0x0000FF)      ) / 255.0f
                            alpha:alpha];
    }
    else {
        return [self blackColor];
    }
	
}

#define FBBHexRed(hex)		FBBHexColor(((hex) & 0xff0000) >> 16)
#define FBBHexGreen(hex)	FBBHexColor(((hex) & 0x00ff00) >>  8)
#define FBBHexBlue(hex)		FBBHexColor(((hex) & 0x0000ff) >>  0)

+(instancetype)colorWithHexInteger:(uint32_t)hex {
	return [self colorWithRed:FBBHexRed(hex) green:FBBHexGreen(hex) blue:FBBHexBlue(hex) alpha:1.0];
}

+(instancetype)userTeamNameTextColor {
	return [self colorWithHexInteger:0xCC0000];
}

+(instancetype)otherTeamNameTextColor {
	return [self colorWithHexInteger:0x1A4D81];
}

+(UIColor *)lighterColorForColor:(UIColor *)c byDegree:(float)degree
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + degree, 1.0)
                               green:MIN(g + degree, 1.0)
                                blue:MIN(b + degree, 1.0)
                               alpha:a];
    return nil;
}

+(UIColor *)darkerColorForColor:(UIColor *)c byDegree:(float)degree
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - degree, 0.0)
                               green:MAX(g - degree, 0.0)
                                blue:MAX(b - degree, 0.0)
                               alpha:a];
    return nil;
}

#pragma mark - Custom Named Colors
+(UIColor *)gdlColorDarkGray
{
    return [UIColor colorWithHex:@"4D4D4D"];
}

+(UIColor *)tileBorderColor
{
    return [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
}

+(UIColor *)tileBorderColorLive
{
    return [UIColor redColor];
}

+ (CGFloat)componentFromColorString:(NSString *)colorString colorName:(NSString *)colorName
{
    unsigned int colorInt;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    [scanner scanHexInt:&colorInt];
    CGFloat color;
    int bitShift = 0;
    
    if ([colorName isEqualToString:@"red"])
        bitShift = 16;
    else if ([colorName isEqualToString:@"green"])
        bitShift = 8;
    if ([colorName isEqualToString:@"blue"])
        bitShift = 0;
    
    // shift the mask left and the result back
    color = (colorInt & (0xFF << bitShift)) >> bitShift;
    return  (CGFloat)color/255.0;
}
@end
