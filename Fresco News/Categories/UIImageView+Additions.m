//
//  UIImageView+Additions.m
//  Fresco
//
//  Created by Omar El-Fanek on 9/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIImageView+Additions.h"

@implementation UIImageView (Additions)

+ (UIImageView *)UIImageViewWithName:(NSString *)imageName andFrame:(CGRect)frame andContentMode:(UIViewContentMode)contentMode{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = contentMode;

    
    return imageView;
    
}


@end
