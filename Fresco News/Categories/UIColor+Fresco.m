//
//  UIColor+Fresco.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIColor+Fresco.h"

@implementation UIColor (Fresco)

+(UIColor *)frescoTabBarColor{
    return [UIColor colorWithWhite:0.13 alpha:1.0]; // opaque
}

+(UIColor *)frescoOrangeColor{
    return [UIColor colorWithRed:1 green:198/255.0 blue:0 alpha:1.0];
}

+(UIColor *)frescoBackgroundColorDark{
    return [UIColor colorWithRed:242/255. green:242/255. blue:237/255. alpha:1];
}

+(UIColor *)frescoBackgroundColorLight{
    return [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

+(UIColor *)frescoGreenColor{
    return [UIColor colorWithRed:76/255.0 green:216/255.0 blue:100/255.0 alpha:1.0];
}

+(UIColor *)frescoDarkTextColor{
    return [UIColor colorWithWhite:0.0 alpha:0.87];
}

+(UIColor *)frescoRedHeartColor{
    return [UIColor colorWithRed:208/255.0 green:2/255.0 blue:27/255.0 alpha:1.0];
}

+(UIColor *)frescoBlueColor{
    return [UIColor colorWithRed:0 green:71/255.0 blue:187/255.0 alpha:1.0];
}

+(UIColor *)frescoMediumTextColor{
    return [UIColor colorWithWhite:0.0 alpha:0.54];
}

+(UIColor *)frescoLightTextColor{
    return [UIColor colorWithWhite:0.0 alpha:0.26];
}

+(UIColor *)frescoShadowColor {
    return [UIColor colorWithWhite:0 alpha:0.12];
}

+(UIColor *)frescoSliderGray {
    return [UIColor colorWithWhite:182.0/255.0 alpha:1.0];
}

@end
