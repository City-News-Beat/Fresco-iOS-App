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
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "NSString+Validation.h"

typedef enum : NSUInteger {
    LoginFresco,
    LoginFacebook,
    LoginTwitter
} LoginType;

@interface FirstRunViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;


@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;


/* Spinner */

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

/*
** Constraints
*/

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;

@end

@implementation FirstRunViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Round buttons
    for (UIButton *button in self.buttons) {
        button.layer.cornerRadius = 4;
        button.clipsToBounds = YES;
    }
    
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
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
                            CGFloat height = 0;
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                height = -6.8 * self.emailField.frame.size.height;
                            }
                            
                            self.topVerticalSpaceConstraint.constant = height;
                            self.bottomVerticalSpaceConstraint.constant = -1 * height;
                            [self.view layoutIfNeeded];
                        } completion:nil];
}

#pragma mark - Controller Functions

/*
** Login Method, takes a LoginType to perform repstive login i.e. facebook, twitter, regular login (fresco)
*/

- (void)performLogin:(LoginType)login button:(UIButton *)button{
    
    self.view.userInteractionEnabled = NO;
    
    [button setTitle:@"" forState:UIControlStateNormal];
    
    CGRect spinnerFrame = CGRectMake(0,0, 20, 20);
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
    
    self.spinner.center = CGPointMake(button.frame.size.width  / 2, button.frame.size.height / 2);
    
    self.spinner.color = [UIColor whiteColor];
    [self.spinner startAnimating];
    
    [button addSubview:self.spinner];
    
    [UIView animateWithDuration:.3 animations:^{
        
        for (UIView *view in [self.view subviews]) {
            if(view != button && view.tag!= 51 && view.tag != 50){
                view.alpha = .26f;
            }

        }
        
    }];
    
    if(login == LoginFresco){
        
        [[FRSDataManager sharedManager] loginUser:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else{
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:INVALID_CREDENTIALS action:nil]
                                   animated:YES completion:^{
                                       [button setTitle:LOGIN forState:UIControlStateNormal];
                                       
                                       [self revertScreenToNormal];
                                       
                                   }];
            }
            
        }];
    
    }
    else if(login == LoginFacebook){
        
        //Facebook icon image
        [self.view viewWithTag:51].hidden = YES;
        
        [[FRSDataManager sharedManager] loginViaFacebookWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else {
                //TODO: check if these are the strings we want
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:FACEBOOK_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:^{
                                     
                                     [button setTitle:FACEBOOK forState:UIControlStateNormal];
                                     
                                     [self revertScreenToNormal];
                                 }];
            
            }
            
        }];
        
    }
    else if(login == LoginTwitter){
        
        //Twitter icon image
        [self.view viewWithTag:50].hidden = YES;

        [[FRSDataManager sharedManager] loginViaTwitterWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else {
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:TWITTER_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:^{
                                     
                                     [button setTitle:TWITTER forState:UIControlStateNormal];
                                     [self revertScreenToNormal];
                                     
                                 }];
                

                
                NSLog(@"%@", error);
                
            }
        }];
        
    }
}

- (void)transferUser{
    
    //Set has Launched Before to prevent onboard from ocurring again
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_HAS_LAUNCHED_BEFORE];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_UPDATE_PROFILE];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePicReset" object:self];
    
    if ([PFUser currentUser].isNew || ![[FRSDataManager sharedManager] currentUserValid]){
        [self performSegueWithIdentifier:SEG_REPLACE_WITH_SIGNUP sender:self];
    }
    else if(![[NSUserDefaults standardUserDefaults] boolForKey:UD_TOS_AGREED]){
        [self performSegueWithIdentifier:SEG_REPLACE_WITH_TOS sender:self];
    }
    else{
        if(self.presentingViewController == nil)
            [self navigateToMainApp];
        else{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)revertScreenToNormal{
    
    self.view.userInteractionEnabled = YES;
    
    //Social Images
    [self.view viewWithTag:50].hidden = NO;
    [self.view viewWithTag:51].hidden = NO;

    [UIView animateWithDuration:.3 animations:^{
        
        self.spinner.alpha = 0;
    
        for (UIView *view in [self.view subviews]) view.alpha = 1;
        
    }];

}

#pragma mark - IBAction Listeners

/*
** Login
*/

- (IBAction)loginButtonAction:(id)sender {
    
    //Check fields first
    if([self.emailField.text isValidEmail]){
    
        [self performLogin:LoginFresco button:self.loginButton];
    
    } else {
        
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:LOGIN_ERROR
                                     message:LOGIN_PROMPT action:nil]
                                       animated:YES completion:nil];
    
    }


}

- (IBAction)facebookLogin:(id)sender{ [self performLogin:LoginFacebook button:self.facebookButton]; }

- (IBAction)twitterLogin:(id)sender { [self performLogin:LoginTwitter button:self.twitterButton]; }

/*
** Signup
*/

- (IBAction)signUpButtonAction:(id)sender
{
    
    [self performSegueWithIdentifier:SEG_SHOW_ACCT_INFO sender:self];
    
}

/*
** "No Thanks, I'll sign up later" button
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
