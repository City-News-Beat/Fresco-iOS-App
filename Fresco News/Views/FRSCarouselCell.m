//
//  FRSCarouselCell.m
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSCarouselCell.h"

@implementation FRSCarouselCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)loadImage:(PHAsset *)asset {
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        [self constrainToEdges:imageView];
        [self addSubview:imageView];
    }
    
    // load resource
}

-(void)loadVideo:(PHAsset *)asset {
    if (!videoView) {
        videoView = [[FRSPlayer alloc] init];
    }
}

-(void)constrainToEdges:(UIView *)view {
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:0 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:0 constant:0];
    [view addConstraints:@[topConstraint,bottomConstraint,leftConstraint,rightConstraint]];
}


@end
