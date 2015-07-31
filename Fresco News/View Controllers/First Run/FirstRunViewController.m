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
    
    // Do any additional setup after loading the view.
    
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
    self.passwordField.returnKeyType = UIReturnKeyDone;
    
    //Set hasLaunchedBefore to prevent onboard from ocurring again
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedBefore"])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedBefore"];
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            CGFloat height = 0;
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                height = -1 * [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
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
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(button.frame.size.width  / 2 - 7, 13,20, 20)];
    
    self.spinner.color = [UIColor whiteColor];
    [self.spinner startAnimating];
    
    [button addSubview:self.spinner];
    
    [UIView animateWithDuration:.3 animations:^{
        
        for (UIView *view in [self.view subviews]) {
            if(view != button)
                view.alpha = .26f;
        }
        
    }];
    
    if(login == LoginFresco){
        
        [[FRSDataManager sharedManager] loginUser:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if (user && [[FRSDataManager sharedManager] isLoggedIn]) {
                
      
                [self transferUser];
                
            }
            else{
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:@"Login Error"
                                             message:@"Invalid Credentials" action:nil]
                                   animated:YES completion:nil];
                
                
                [button setTitle:@"Login" forState:UIControlStateNormal];
                
                [self revertScreenToNormal];
                
            }
            
        }];
    
    }
    else if(login == LoginFacebook){
        
        [[FRSDataManager sharedManager] loginViaFacebookWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if (user) {
                
                [self transferUser];
                
            }
            else {
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:@"Login Error"
                                             message:@"We ran into an error signing you in with Twitter"
                                             action:@"Dismiss"]
                                   animated:YES
                                 completion:nil];
                
                [button setTitle:@"Facebook" forState:UIControlStateNormal];
                
                [self revertScreenToNormal];
            }
            
        }];
        
    }
    else if(login == LoginTwitter){
        
        
        [[FRSDataManager sharedManager] loginViaTwitterWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if (user) {
                
                [self transferUser];
                
            }
            else {
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:@"Login Error"
                                             message:@"We ran into an error signing you in with Twitter"
                                             action:@"Dismiss"]
                                   animated:YES
                                 completion:nil];
                
                [self revertScreenToNormal];
                
                [button setTitle:@"Twitter" forState:UIControlStateNormal];
                
                NSLog(@"%@", error);
                
            }
        }];
        
    }
}

- (void)revertScreenToNormal{
    
    self.view.userInteractionEnabled = YES;

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
    if(self.emailField.text && self.emailField.text.length > 0
       && self.passwordField.text && self.passwordField.text.length > 0){
    
        [self performLogin:LoginFresco button:self.loginButton];
    
    }
    else{
        
        
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:@"Login Error"
                                     message:@"Please enter an Email & Password to Login" action:nil]
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
    [self performSegueWithIdentifier:@"showAccountInfo" sender:self];
}

- (IBAction)buttonWontLogin:(UIButton *)sender {

    [self navigateToMainApp];

}

- (void)transferUser{
    
    if ([PFUser currentUser].isNew || ![[FRSDataManager sharedManager] currentUserValid]){
        [self performSegueWithIdentifier:@"replaceWithSignUp" sender:self];
    }
    else
        [self navigateToMainApp];
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
    if ([[segue identifier] isEqualToString:@"showAccountInfo"]) {
        FirstRunAccountViewController *fracvc = [segue destinationViewController];
        fracvc.email = self.emailField.text;
        fracvc.password = self.passwordField.text;
    }
}

@end
