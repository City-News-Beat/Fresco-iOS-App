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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerTapped:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
        
        
        // Create back button
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(24, 8, 38, 24);
        backButton.alpha = .54;
//        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [backButton.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        backButton.userInteractionEnabled = YES;
        
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        
        [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:backButton];
        
        
        // Create back carret
        UIImageView *backCaret = [[UIImageView alloc] initWithFrame:CGRectMake(8, 12, 12, 15)];
        backCaret.image = [UIImage imageNamed:@"backCaret"];
        [backCaret setContentMode:UIViewContentModeScaleAspectFill];
        
        [self addSubview:backCaret];
        
        
 
        CGRect frame = self.frame;
//        self.backgroundColor = [UIColor redColor];
    }
    
    
    
    return self;
    
}

- (void)gestureRecognizerTapped:(NSNotification*)sender{
    
    NSLog(@"Gesture recognizer tapped!");
    [self tappedAnimation];

}


- (IBAction)backButtonTapped:(id)sender {
    
//    [self.navigationController popViewControllerAnimated:YES];
    
    NSLog (@"Back button tapped!");
    [self tappedAnimation];
    
    
}


- (void)tappedAnimation {
    //bump down alpha of button and carot for duration 0.4
}

@end
