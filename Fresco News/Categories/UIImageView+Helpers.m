//
//  UIImageView+Helpers.m
//  Fresco
//
//  Created by Omar Elfanek on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "UIImageView+Helpers.h"

@implementation UIImageView (Helpers)

+ (UIImageView *)UIImageViewWithName:(NSString *)imageName andFrame:(CGRect)frame andContentMode:(UIViewContentMode)contentMode{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = contentMode;
    
    
    return imageView;
    
}

@end
