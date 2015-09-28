//
//  FRSBackButton.m
//  Fresco
//
//  Created by Omar El-Fanek on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBackButton.h"


@interface FRSBackButton ()

//@property (strong, nonatomic) UIButton *backButton;
//
//@property (strong, nonatomic) UIImage *backCaret;

//@property (strong, nonatomic) UINavigationController *navigationController;

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
    self.alpha = .54;
    [self.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addTarget:self.delegate action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTitle:@"Back" forState:UIControlStateNormal];
    

    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self setImage:[UIImage imageNamed:@"backCaretDark"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"backCaretLight"] forState:UIControlStateHighlighted];


}

@end
