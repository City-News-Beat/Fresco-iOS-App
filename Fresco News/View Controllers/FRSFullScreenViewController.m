//
//  FRSFullScreenViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 6/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFullScreenViewController.h"
#import "FRSFullScreenCloseButton.h"
#import "FRSFullScreenUserFooterView.h"
#import "FRSUserManager.h"

@interface FRSFullScreenViewController ()

@property BOOL shouldDisplayStatusBar;

@end

@implementation FRSFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}

- (void)configureUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self toggleStatusBar];
    
    [self configureCloseButton];
    [self configureUserFooter];
}



#pragma mark - Close Button
- (void)configureCloseButton {
    FRSFullScreenCloseButton *closeButton = [[FRSFullScreenCloseButton alloc] init];
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

-(void)closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self toggleStatusBar];
}


#pragma mark - User Footer
- (void)configureUserFooter {
    
    FRSFullScreenUserFooterView *footerView = [[FRSFullScreenUserFooterView alloc] initWithUser:[[FRSUserManager sharedInstance] authenticatedUser] delegate:self];
    [self.view addSubview:footerView];
    
}



#pragma mark - Status Bar
- (void)toggleStatusBar {
    UIWindow *statusBarApplicationWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    [UIView beginAnimations:@"fade-statusbar" context:nil];
    [UIView setAnimationDuration:0.3];
    statusBarApplicationWindow.alpha = self.shouldDisplayStatusBar;
    [UIView commitAnimations];
    
    self.shouldDisplayStatusBar = self.shouldDisplayStatusBar ? NO : YES;
}

@end
