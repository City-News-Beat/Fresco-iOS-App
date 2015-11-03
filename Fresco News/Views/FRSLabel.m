//
//  FRSLabel.m
//  Fresco
//
//  Created by Elmir Kouliev on 9/24/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLabel.h"

@implementation FRSLabel

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){
    
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, frame.size.height - 1, frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
        [self.layer addSublayer:bottomBorder];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0, 0, frame.size.width, 1.0f);
        topBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
        [self.layer addSublayer:topBorder];
    }
    
    return self;

}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 16, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end