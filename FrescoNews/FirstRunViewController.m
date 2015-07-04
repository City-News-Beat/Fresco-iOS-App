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
#import "AppDelegate.h"

@interface FirstRunViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end

@implementation FirstRunViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self styleButtons];
    
    // this allows us to NEXT to fields
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedBefore"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedBefore"];
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)styleButtons {
    self.loginButton.layer.cornerRadius = 4;
    self.loginButton.clipsToBounds = YES;
    
    self.signUpButton.layer.cornerRadius = 4;
    self.signUpButton.clipsToBounds = YES;
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

- (IBAction)loginButtonAction:(id)sender {
    self.loginButton.enabled = NO;
    [[FRSDataManager sharedManager] loginUser:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        self.loginButton.enabled = YES;
        if (user) {
            FRSUser *frsUser = [FRSDataManager sharedManager].currentUser;
            
            // make sure first and last name are set
            // if not collect them
            if (!([frsUser.first length] && [frsUser.last length])) {
                [self performSegueWithIdentifier:@"replaceWithSignUp" sender:self];
            }
            // otherwise just go into the app
            else {
                AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                // TODO: Move location setup calls to -navigateToMainApp or FRSDataManager
                [appDelegate setupLocationManager];
                [appDelegate setupLocationMonitoring];
                [self.view endEditing:YES];
                [self navigateToMainApp];
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed" delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            self.emailField.textColor = [UIColor redColor];
        }
    }];
}

- (IBAction)signUpButtonAction:(id)sender
{
    [self performSegueWithIdentifier:@"showAccountInfo" sender:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //[self.loginButtonAction:sender];
        [self.passwordField resignFirstResponder];
    }
    return YES;
}

- (IBAction)facebookLogin:(id)sender
{
    [[FRSDataManager sharedManager] loginViaFacebookWithBlock:^(PFUser *user, NSError *error) {
        if (user) {
            if (user.isNew)
                [self performSegueWithIdentifier:@"replaceWithSignUp" sender:self];
            else {
                // check to see if the user finished signup
                if ([[FRSDataManager sharedManager] currentUserValid])
                    [self navigateToMainApp];
                // user didn't complete a prior signup flow
                else
                    [self performSegueWithIdentifier:@"replaceWithSignUp" sender:self];
            }
        }
        else {
            NSLog(@"Facebook login error: %@", error);
        }
    }];
}

- (IBAction)twitterLogin:(id)sender {
    [[FRSDataManager sharedManager] loginViaTwitterWithBlock:^(PFUser *user, NSError *error) {
        if (user) {
            if (user.isNew)
                [self performSegueWithIdentifier:@"replaceWithSignUp" sender:self];
            else {
                // check to see if the user finished signup
                if ([[FRSDataManager sharedManager] currentUserValid])
                    [self navigateToMainApp];
                // user didn't complete a prior signup flow
                else
                    [self performSegueWithIdentifier:@"replaceWithSignUp" sender:self];
            }
        }
        else {
            NSLog(@"Twitter login error: %@", error);
        }
    }];
}

- (IBAction)buttonWontLogin:(UIButton *)sender {
    [self navigateToMainApp];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // normal push segue for Fresco signup
    if ([[segue identifier] isEqualToString:@"showAccountInfo"]) {
        FirstRunAccountViewController *fracvc = [segue destinationViewController];
        fracvc.email = self.emailField.text;
        fracvc.password = self.passwordField.text;
    }
    
    // custom replace segue for social signup
    else if ([[segue identifier] isEqualToString:@"replaceWithSignUp"]) {
        
    }
}

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

- (IBAction)forgotPassword:(id)sender {
    NSString *email = self.emailField.text;
    if (![email length])
        email = [FRSDataManager sharedManager].currentUser.email;
    
    if ([email length]) {
        [PFUser requestPasswordResetForEmailInBackground:email
                                                   block:^(BOOL succeeded, NSError *error) {
                                                       if (!error) {
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                                                           message:@"Email sent. Follow the instructions in the email to change your password."
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:@"Dismiss"
                                                                                                 otherButtonTitles:nil];
                                                           [alert show];
                                                       }
                                                       else {
                                                           NSLog(@"Error: %@", error);
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                                                           message:@"This email has not been registered."
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:@"Dismiss"
                                                                                                 otherButtonTitles:nil];
                                                           [alert show];
                                                       }
                                                   }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter an email address"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
