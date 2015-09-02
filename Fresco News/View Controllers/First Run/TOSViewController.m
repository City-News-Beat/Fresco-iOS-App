//
//  FirstRunTOSViewController.m
//  Fresco
//
//  Created by Zachary Mayberry on 7/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "TOSViewController.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "UIViewController+Additions.h"

@interface TOSViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tosTextView;

@end

@implementation TOSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupView];
   
    [self getTermsFromServer];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

/*
 ** pull TOS from server
 */

- (void)getTermsFromServer {
    
    [[FRSDataManager sharedManager] getTermsOfService:NO withResponseBlock:^(id responseObject, NSError *error) {
        
        if (error || responseObject == nil) {
            
            self.tosTextView.text = T_O_S_UNAVAILABLE_MSG;
            
        }
        else {
            
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
    

    if(self.agreedState){
        
        UIBarButtonItem *logoutBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTermsWithLogout)];
        
        self.navigationItem.leftBarButtonItem = logoutBarButtonItem;
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
        
        UIBarButtonItem *agreeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Agree" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTerms)];
        self.navigationItem.rightBarButtonItem = agreeBarButtonItem;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor frescoBlueColor];

    }
    else{
        
        UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTerms)];
        self.navigationItem.rightBarButtonItem = closeBarButtonItem;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor textHeaderBlackColor];
    
    }
    
    self.view.backgroundColor = [UIColor whiteBackgroundColor];
    [[self.view viewWithTag:30] setBackgroundColor:[UIColor whiteBackgroundColor]];
    
    self.tosTextView.text = @"";
    
    self.tosTextView.textContainerInset = UIEdgeInsetsMake(10, 16, 10, 16);
}


/*
** Close button is hit, exiting TOS view
*/

- (void)dismissTerms{
    
    //If we're in the agreed state, send response to server setting user as agreed to the latest TOS
    if(self.agreedState)
        [[FRSDataManager sharedManager] agreeToTOS:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissTermsWithLogout{
    
    [[FRSDataManager sharedManager] logout];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end