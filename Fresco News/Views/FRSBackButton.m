//
//  FRSBackButton.m
//  Fresco
//
//  Created by Omar El-Fanek on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBackButton.h"

#import "UIImage+Helpers.h"

@implementation FRSBackButton

+ (FRSBackButton *)createBackButton{

    FRSBackButton *button = [FRSBackButton buttonWithType:UIButtonTypeSystem];
    
    [button setUpBackButton];
    
    return button;
}

+(FRSBackButton *)createLightBackButtonWithTitle:(NSString *)title {
    
    FRSBackButton *button = [FRSBackButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(-1, 31, 78, 20);
    [button.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    
    button.layer.shadowColor = [UIColor frescoShadowColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 2);
    button.layer.shadowOpacity = 1.0;
    button.layer.shadowRadius = 2.0;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [button addTarget:button.delegate action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
//    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [button setImage:[UIImage imageNamed:@"back-arrow-white"] forState:UIControlStateNormal];
    
    return button;
}

/**
 *  Extracted method to configure button's appearance when initialized
 */

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
