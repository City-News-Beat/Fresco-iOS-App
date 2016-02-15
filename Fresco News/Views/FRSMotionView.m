//
//  FRSMotionView.m
//  Fresco
//
//  Created by Team Fresco on 3/4/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSMotionView.h"
#import "UIScrollView+CRScrollIndicator.h"

@interface FRSMotionView ()

@end

@implementation FRSMotionView

- (void)setImage:(UIImage *)image
{
    [[self scrollView] cr_disableScrollIndicator];
    [super setImage:image];
}

@end
