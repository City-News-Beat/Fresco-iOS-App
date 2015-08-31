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

@interface FirstRunTOSViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tosTextView;

@end

@implementation FirstRunTOSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupView];
    
    [self getTermsFromServer];
}


/*
 ** pull TOS from server
 */

- (void)getTermsFromServer {
    
    [[FRSDataManager sharedManager] getTermsOfService:^(id responseObject, NSError *error) {
        if (error || responseObject == nil) {
            self.tosTextView.text = T_O_S_UNAVAILABLE_MSG;
            
        } else {
            
            [self.tosTextView setText:responseObject[@"data"]];
        }
        
        [self.tosTextView setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.54]];
        
        self.tosTextView.font = [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:11];
        
    }];
}


/*
 ** Set up TOS UI
 */

- (void)setupView {
    
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
    
    self.tosTextView.text = @"";
}


/*
** Close button is hit, exiting TOS view
*/

- (void)dismissTerms {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end