//
//  FRSRoundedView.h
//  Fresco
//
//  Created by Daniel Sun on 11/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSRoundedView : UIView

- (id)initWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth;

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;



@end
