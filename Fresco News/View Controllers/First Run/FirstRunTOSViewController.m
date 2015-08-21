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

@interface FirstRunTOSViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UITextView *tosTextView;
// @property (nonatomic) BOOL monitorScrolling;
@end

@implementation FirstRunTOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.agreeButton.enabled = YES; // But probably we want to require scrolling to the end first

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
    
}

/*
** Final step of First Run
*/

- (IBAction)actionDone:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_TOS_AGREED];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self dismissViewControllerAnimated:YES completion:nil];
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

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (!self.monitorScrolling) {
//        return;
//    }
//
//    if (scrollView.contentOffset.y + scrollView.frame.size.height /* the bottom edge */ >= scrollView.contentSize.height) {
//        // we are at the end
//        self.agreeButton.enabled = YES;
//    }
//}

@end
