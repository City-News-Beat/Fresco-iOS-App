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

@interface FirstRunTOSViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UITextView *tosTextView;
@property (weak, nonatomic) IBOutlet UIImageView *progressBarImageView;
@property (nonatomic) BOOL didScrollToBottomOnce;
@end

@implementation FirstRunTOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agreeButton.enabled = YES; // But probably we want to require scrolling to the end first
    self.didScrollToBottomOnce = NO;
    
    // No text appears at requested font size 14.0 - constraint issue?
    self.tosTextView.font = [UIFont systemFontOfSize:12.0];
    
    if (IS_STANDARD_IPHONE_6_PLUS) {
        self.tosTextView.font = [UIFont systemFontOfSize:11.6];
    }
    
    self.tosTextView.text = @"";
    [[FRSDataManager sharedManager] getTermsOfService:^(id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.tosTextView.text = T_O_S_UNAVAILABLE_MSG;
                // self.monitorScrolling = YES; // for now
            }
            else {
                self.tosTextView.text = responseObject[@"data"];
                // self.monitorScrolling = YES;
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
    if (self.updatedTerms) {
        self.progressBarImageView.hidden = YES;
        self.agreeButton.backgroundColor = [UIColor disabledToolbarColor];
        [self.agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.progressBarImageView.hidden = NO;
        self.agreeButton.backgroundColor = [UIColor whiteColor];
        [self.agreeButton setTitleColor:[UIColor disabledToolbarColor] forState:UIControlStateNormal];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

/*
** Final step of First Run
*/

- (IBAction)actionDone:(id)sender
{
    if (self.didScrollToBottomOnce) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_TOS_AGREED];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        
        [UIView animateWithDuration:1 delay:1 options:0 animations:^{
            self.agreeButton.userInteractionEnabled = NO;
            
        } completion:^(BOOL finished) {
            self.agreeButton.userInteractionEnabled = YES;
            
        }];
    }
    
}

- (IBAction)actionCancel:(id)sender {
    
    UIAlertController *logOutAlertController = [[FRSAlertViewManager sharedManager] alertControllerWithTitle:@"Are you sure?" message:@"The terms of service are what give us permission to show you nearby assignments and get your photos and videos seen and paid for by news outlets." action:CANCEL];
    
    [logOutAlertController addAction:[UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [[FRSDataManager sharedManager] logout];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UD_TOS_AGREED];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self dismissViewControllerAnimated:YES completion:nil];
        
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

    if ([self didScrollToBottomOfScrollView:scrollView]) {
        
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
