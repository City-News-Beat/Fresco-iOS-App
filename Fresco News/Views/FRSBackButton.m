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
        
//        // Create Gesture Recognizers
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerTapped:)];
//        self.userInteractionEnabled = YES;
//        [self addGestureRecognizer:tap];
//        
//        UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBegan:)];
//        self.userInteractionEnabled = YES;
//        [self addGestureRecognizer:hold];
//        
//        // Create back button
//        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.backButton.frame = CGRectMake(24, 8, 45, 24);
//        self.backButton.alpha = .54;
////        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
//        [self.backButton.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
//        [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
////        self.backButton.userInteractionEnabled = YES;
//        
//        [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
//        
//        [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchDown];
//
//        [self addSubview:self.backButton];
//        
//        // Create back carret
//        self.backCaret = [[UIImageView alloc] initWithFrame:CGRectMake(8, 12, 12, 15)];
//        self.backCaret.image = [UIImage imageNamed:@"backCaret"];
//        [self.backCaret setContentMode:UIViewContentModeScaleAspectFill];
//        
//        [self addSubview:self.backCaret];
//        
//        self.backgroundColor = [UIColor redColor];
//        
//        self.backButton.userInteractionEnabled = NO;
        
        
        [self setUpBackButton];

    }
    
    return self;
}

//-(IBAction)longPressBegan:(UILongPressGestureRecognizer *)recognizer
//{
//    
//    recognizer.minimumPressDuration = .1;
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan)
//    {
//        self.backButton.alpha = 0.14;
//        self.backCaret.alpha = 0.6;
//    }
//    
//    else
//    {
//        if (recognizer.state == UIGestureRecognizerStateCancelled
//            || recognizer.state == UIGestureRecognizerStateFailed
//            || recognizer.state == UIGestureRecognizerStateEnded)
//        {
//            self.backButton.alpha = 0.54;
//            self.backCaret.alpha = 1.0;
//        }
//    }
//}
//
//
//- (void)gestureRecognizerTapped:(NSNotification*)sender{
//    
//    [self tappedAnimation];
//}
//
//
//- (IBAction)backButtonTapped:(id)sender {
//    
////    [self.navigationController popViewControllerAnimated:YES];
//    
//    [self tappedAnimation];
//    
//}
//
//
//- (void)tappedAnimation {
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [UIView animateWithDuration:0.15
//                         animations:^{
//                             self.backButton.alpha = 0.14;
//                             self.backCaret.alpha = 0.6;
//                             
//                         } completion:^(BOOL finished) {
//
//                             [UIView animateWithDuration: 0.1 animations:^{
//                                 
//                                 self.backButton.alpha = 0.54;
//                                 self.backCaret.alpha = 1.0;
//                                 
//                             }];
//                             
//                         }];
//    });
//    
//}
//
//- (void)holdAnimation {
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [UIView animateWithDuration:0.15
//                         animations:^{
//                             self.backButton.alpha = 0.14;
//                             self.backCaret.alpha = 0.6;
//                             
//                         }];
//    });
//    
//}




- (void)setUpBackButton {
    
    // Create back button
    
    
//    self = [UIButton buttonWithType:UIButtonTypeSystem];
    self.frame = CGRectMake(4, 24, 70, 24);
    self.alpha = .54;
    [self.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addTarget:self.delegate action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchDown];
    
    [self setTitle:@"Back" forState:UIControlStateNormal];
    

    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self setImage:[UIImage imageNamed:@"backCaretDark"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"backCaretLight"] forState:UIControlStateHighlighted];
    
    
//    self.backgroundColor = [UIColor redColor];

}



//- (IBAction)backButtonTapped:(id)sender {
//    
////    UINavigationController *navController = [[UINavigationController alloc] init];
//    
////    [self.navigationController popViewControllerAnimated:YES];
//    
////    [self.frsBackButtonDelegate backButtonTapped];
//    
//    NSLog (@"back button tapped");
//    
//}





@end
