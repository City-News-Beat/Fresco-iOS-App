//
//  FRSRoundedView.m
//  Fresco
//
//  Created by Daniel Sun on 11/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSRoundedView.h"

@interface FRSRoundedView()

//@property (strong, nonatomic) UIView *overlay;
//
//@property (strong, nonatomic) UILongPressGestureRecognizer *gr;

@end

@implementation FRSRoundedView

- (id)initWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth {
    if (self = [super init]) {
        self.borderWidth = borderWidth;
        self.borderColor = UIColor.whiteColor;
        
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        self.imageView.layer.masksToBounds = YES;
        self.layer.masksToBounds = YES;
        
//        self.gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(darkenImage:)];
//        self.gr.minimumPressDuration = 0.1;
//        [self addGestureRecognizer:self.gr];
        
    }
    return self;
}

//-(void)darkenImage:(UILongPressGestureRecognizer *)gr{
//    switch (gr.state) {
//        case UIGestureRecognizerStateBegan: // object pressed
//        case UIGestureRecognizerStateChanged:
//            self.overlay.alpha = 1;
//            break;
//        case UIGestureRecognizerStateEnded: // object released
//            self.overlay.alpha = 0.0;
//            break;
//        default: // unknown tap
//            NSLog(@"%i", gr.state);
//            break;
//    }
//}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.backgroundColor = borderColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshDimensions];
}

- (void)refreshDimensions {
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.f;
    
    self.imageView.frame = CGRectInset(self.bounds, _borderWidth, _borderWidth);
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.bounds) / 2.f;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self refreshDimensions];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self refreshDimensions];
}

@end
