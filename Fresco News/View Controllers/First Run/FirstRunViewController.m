//
//  FirstRunViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Parse;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FirstRunViewController.h"
#import "FirstRunAccountViewController.h"
#import "TOSViewController.h"
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "NSString+Validation.h"
#import "UISocialButton.h"

@interface FirstRunViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

@property (weak, nonatomic) IBOutlet UISocialButton *twitterButton;
@property (weak, nonatomic) IBOutlet UISocialButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation FirstRunViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.parentViewController.view.backgroundColor = [UIColor frescoGreyBackgroundColor];
    
    //Round buttons
    for (UIButton *button in self.buttons) {
        button.layer.cornerRadius = 4;
        button.clipsToBounds = YES;
    }
    
    [self.twitterButton setUpSocialIcon:SocialNetworkTwitter];
    [self.facebookButton setUpSocialIcon:SocialNetworkFacebook];
    
    // Add shadow above Dismiss Button
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dismissButton.frame.size.width, 1)];
    shadowView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.08];
    [self.dismissButton addSubview:shadowView];
    
    //This allows us to NEXT to fields
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    //Set return buttons
    self.emailField.returnKeyType = UIReturnKeyNext;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    
    [self setupLoginButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Text Field and Keyboard Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
        
    } else if (textField == self.passwordField) {
        [self.passwordField resignFirstResponder];
        
        if ([self.emailField.text length] == 0 && [self.passwordField.text length] == 0) {
            
            [self performSegueWithIdentifier:SEG_SHOW_ACCT_INFO sender:self];
            
        } else {
            [self loginButtonAction:self];
        }
    }
    
    return NO;
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.3
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{

                            CGRect viewFrame = self.view.frame;

                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]){
                                
                                viewFrame.origin.y = -130;
                            }
                            else if([notification.name isEqualToString:UIKeyboardWillHideNotification])
                                viewFrame.origin.y = 0;
                            
                            self.view.frame = viewFrame;
                        
                        } completion:nil];
}


#pragma mark - IBAction Listeners

/*
** Login
*/

- (void)setupLoginButton {
    
    [self.loginButton setTitleColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:1] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:.1] forState:UIControlStateHighlighted];
    
}

- (IBAction)loginButtonAction:(id)sender {
    
    //Check fields first
    if([self.emailField.text isValidEmail]){
    
        [self performLogin:LoginFresco button:self.loginButton
             withLoginInfo:@{@"email" : self.emailField.text,
                             @"password" : self.passwordField.text
                             }];
    
    } else {
        
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:LOGIN_ERROR
                                     message:LOGIN_PROMPT action:nil]
                                       animated:YES completion:nil];
    
    }


}

- (IBAction)facebookLogin:(id)sender{
    [self performLogin:LoginFacebook button:self.facebookButton withLoginInfo:nil];
}

- (IBAction)twitterLogin:(id)sender {
    [self performLogin:LoginTwitter button:self.twitterButton withLoginInfo:nil];
}

/*
** Signup Button
*/

- (IBAction)signUpButtonAction:(id)sender
{
    
    [self performSegueWithIdentifier:SEG_SHOW_ACCT_INFO sender:self];
    
}

/*
** "No Thanks, I'll sign up later" Button
*/

- (IBAction)buttonWontLogin:(UIButton *)sender {
    
    //Set has Launched Before to prevent onboard from ocurring again
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_HAS_LAUNCHED_BEFORE];
    
    if(self.presentingViewController == nil){
        [self navigateToMainApp];
    }
    else{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)forgotPassword:(id)sender {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forgot",BASE_URL]]];
    
}

#pragma mark - Touch Handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([self.emailField isFirstResponder] && [touch view] != self.emailField) {
        [self.emailField resignFirstResponder];
    }
    
    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // normal push segue for Fresco signup
    if ([[segue identifier] isEqualToString:SEG_SHOW_ACCT_INFO]) {
        FirstRunAccountViewController *fracvc = [segue destinationViewController];
        fracvc.email = self.emailField.text;
        fracvc.password = self.passwordField.text;
    }
}

@end
