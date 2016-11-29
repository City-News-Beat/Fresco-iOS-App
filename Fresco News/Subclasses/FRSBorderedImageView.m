//
//  FRSBorderedImageView.m
//  Fresco
//
//  Created by Daniel Sun on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBorderedImageView.h"

@interface FRSBorderedImageView()

@property (strong, nonatomic) UIView *borderView;

@end

@implementation FRSBorderedImageView

-(instancetype)initWithFrame:(CGRect)frame borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    self = [super initWithFrame:frame];
    if (self){
        self.borderView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, -0.5, self.frame.size.width + 1, self.frame.size.height + 1)];
        self.borderView.layer.cornerRadius = (self.frame.size.width + 1)/2;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        self.borderView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.borderView];
    }
    return self;
}



-(void)setBorderColor:(UIColor *)borderColor{
    self.borderView.layer.borderColor = borderColor.CGColor;
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    self.borderView.layer.borderWidth = borderWidth;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
