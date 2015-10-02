//
//  FRSBackButton.m
//  Fresco
//
//  Created by Omar El-Fanek on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBackButton.h"

@implementation FRSBackButton

+ (FRSBackButton *)createBackButton{

    FRSBackButton *button = [FRSBackButton buttonWithType:UIButtonTypeSystem];
    
    [button setUpBackButton];
    
    return button;
}


- (void)setUpBackButton {
        
    self.frame = CGRectMake(4, 24, 70, 24);
    [self.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self addTarget:self.delegate action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTitle:@"Back" forState:UIControlStateNormal];


    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self setImage:[UIImage imageNamed:@"backCaretDark"] forState:UIControlStateNormal];
    
    [self setTitleColor:[UIColor colorWithRed:0.46 green:0.46 blue:0.46 alpha:1] forState:UIControlStateNormal];
    
    [self setTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];

}


@end
