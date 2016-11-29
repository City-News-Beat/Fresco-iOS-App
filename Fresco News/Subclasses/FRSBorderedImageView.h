//
//  FRSBorderedImageView.h
//  Fresco
//
//  Created by Daniel Sun on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSBorderedImageView : UIImageView

@property (strong, nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;

-(instancetype)initWithFrame:(CGRect)frame borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

@end
