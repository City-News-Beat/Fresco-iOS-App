//
//  FirstRunTOSViewController.m
//  Fresco
//
//  Created by Zachary Mayberry on 7/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunTOSViewController.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "UIViewController+Additions.h"

@interface FirstRunTOSViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UITextView *tosTextView;
@property (weak, nonatomic) IBOutlet UIImageView *progressBarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHeight;

@property (assign, nonatomic) BOOL didScrollToBottomOnce;

@end

@implementation FirstRunTOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nil"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.topItem.title = @"Terms of Service";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor textInputBlackColor]}];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTerms)];
    
    self.navigationItem.rightBarButtonItem = closeBarButtonItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor textHeaderBlackColor];
    self.view.backgroundColor = [UIColor whiteBackgroundColor];
    [[self.view viewWithTag:30] setBackgroundColor:[UIColor whiteBackgroundColor]];
    
    self.agreeButton.enabled = YES; // But probably we want to require scrolling to the end first
    self.didScrollToBottomOnce = NO;
    
    // No text appears at requested font size 14.0 - constraint issue?
    self.tosTextView.text = @"";
    
    
    
    [[FRSDataManager sharedManager] getTermsOfService:^(id responseObject, NSError *error) {
        if (error || responseObject == nil) {
            self.tosTextView.text = T_O_S_UNAVAILABLE_MSG;
            // self.monitorScrolling = YES; // for now
        }
        else {
            
            [self.tosTextView setText:responseObject[@"data"]];
        }
        
        [self.tosTextView setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.54]];
        
        self.tosTextView.font = [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:11];
        
    }];
    
}

/*
** Final step of First Run, "Agreed" button
*/

- (IBAction)actionDone:(id)sender
{
    //Check if we've hit the bottom of the scrol view yet
    if (self.didScrollToBottomOnce) {
        

        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
        if(self.presentingViewController == nil)
            [self navigateToMainApp];
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
    //Send us to the bottom if not reached yet, and make sure we have updated TOS
    else if(![self.tosTextView.text isEqualToString:T_O_S_UNAVAILABLE_MSG]) {
        
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        
        [UIView animateWithDuration:1 delay:1 options:0 animations:^{
            self.agreeButton.userInteractionEnabled = NO;
            
        } completion:^(BOOL finished) {
            self.agreeButton.userInteractionEnabled = YES;
            
        }];
    }
    
}

/*
** Cancel button is hit, exiting TOS view
*/

- (void)dismissTerms {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCancel:(id)sender {
    
    UIAlertController *logOutAlertController = [[FRSAlertViewManager sharedManager] alertControllerWithTitle:@"Are you sure?" message:@"The terms of service are what give us permission to show you nearby assignments and get your photos and videos seen and paid for by news outlets." action:CANCEL];
    
    [logOutAlertController addAction:[UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [[FRSDataManager sharedManager] logout];

        if(self.presentingViewController == nil)
            [self navigateToMainApp];
        else{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }]];
    
    [self presentViewController:logOutAlertController animated:YES completion:nil];
    
}

- (BOOL)didScrollToBottomOfScrollView: (UIScrollView *)scrollView {
    
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        return YES;
    
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if ([self didScrollToBottomOfScrollView:scrollView] && !self.didScrollToBottomOnce) {

        self.didScrollToBottomOnce = YES;
        
        self.agreeButton.userInteractionEnabled = YES;
        
        if (self.updatedTerms) {
            self.agreeButton.backgroundColor = [UIColor greenToolbarColor];
        } else {
            [self.agreeButton setTitleColor:[UIColor goldStatusBarColor] forState:UIControlStateNormal];
        }

    }
}

@end