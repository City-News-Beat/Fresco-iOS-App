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
    [self setTitleColor:[UIColor textHeaderBlackColor] forState:UIControlStateNormal];
    [self setTitle:@"Back" forState:UIControlStateNormal];
    [self setTintColor:[UIColor textHeaderBlackColor]];
    
    [self addTarget:self.delegate action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self setImage:[UIImage imageNamed:@"backCaretDark"] forState:UIControlStateNormal];
    

}



@end
