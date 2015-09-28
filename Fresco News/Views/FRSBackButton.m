//
//  FRSBackButton.m
//  Fresco
//
//  Created by Omar El-Fanek on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBackButton.h"


@interface FRSBackButton ()

@end

@implementation FRSBackButton

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
   
        [self setUpBackButton];

    }
    
    return self;
}




- (void)setUpBackButton {
    
    // Create back button
    
    self.frame = CGRectMake(4, 24, 70, 24);
    [self.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self addTarget:self.delegate action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTitle:@"Back" forState:UIControlStateNormal];
    

    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self setImage:[UIImage imageNamed:@"backCaretDark"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"backCaretLight"] forState:UIControlStateHighlighted];

 
    
    [self setTitleColor:[UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor colorWithRed:0.46 green:0.46 blue:0.46 alpha:1] forState:UIControlStateNormal];
}







@end
