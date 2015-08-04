//
//  AssignmentOnboardViewController.m
//  Fresco
//
//  Created by Nicolas Rizk on 7/30/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AssignmentOnboardViewController.h"

@interface AssignmentOnboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *onboard1Label;
@property (weak, nonatomic) IBOutlet UILabel *onboard2Label;
@property (weak, nonatomic) IBOutlet UILabel *onboard3Label;
@property (weak, nonatomic) IBOutlet UIButton *letsGoButton;
- (IBAction)letsGoButtonTapped:(id)sender;

@end

@implementation AssignmentOnboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.view.bounds;
    [self.view addSubview:visualEffectView];
    [self.view sendSubviewToBack:visualEffectView];
    
    [[UILabel appearance] setNumberOfLines:3];
    [self.onboard1Label setText:@"Look around the map to see what’s\nhappening. Tap on the yellow dots\nto see more info and get directions."];
    
    [self.onboard2Label setText:@"When the camera says you’re close\nenough, you’re ready to start taking\nphotos and videos!"];
    
    [self.onboard3Label setText:@"If a photo or video in your gallery is\nused, we’ll tell you who used it and\nhow to get paid!"];
    
    [self.letsGoButton setBackgroundColor:[UIColor frescoBlueColor]];
    self.letsGoButton.layer.cornerRadius = 4;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        // if iPhone 5
        if (screenSize.height < 667.0f) {
            
            for (UILabel *label in @[self.onboard1Label, self.onboard2Label, self.onboard3Label]) {
                [label setFont:[UIFont fontWithName:HELVETICA_NEUE_LIGHT size:13]];
            }
        }
    }
}


- (IBAction)letsGoButtonTapped:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    }];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"assignmentsOnboarding"];
}
@end
