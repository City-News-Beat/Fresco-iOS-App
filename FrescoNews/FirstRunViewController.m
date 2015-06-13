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
#import "FRSDataManager.h"

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
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    
    self.signUpButton.layer.cornerRadius = 8;
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
    [[FRSDataManager sharedManager] loginUser:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            FRSUser *frsUser = [FRSDataManager sharedManager].currentUser;
            
            // make sure first and last name are set
            if (!([frsUser.first length] && [frsUser.last length])) {
                [self performSegueWithIdentifier:@"showSignUp" sender:self];
            }
            else {
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
    if ([self.emailField.text length] == 0 || [self.passwordField.text length] == 0) {
        [self performSegueWithIdentifier:@"showInitialSignUp" sender:self];
        return;
    }
    else {
    
        [[FRSDataManager sharedManager] signupUser:self.emailField.text
                                              email:self.emailField.text
                                           password:self.passwordField.text
                                              block:^(BOOL succeeded, NSError *error) {
                                                  if (!error)
                                                      [self performSegueWithIdentifier:@"showSignUp" sender:self];
                                                  else {
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                      message:@"Signup failed"
                                                                                                     delegate: self
                                                                                            cancelButtonTitle: @"Cancel"
                                                                                            otherButtonTitles:nil, nil];
                                                      [alert addButtonWithTitle:@"Try Again"];
                                                      [alert show];
                                                      
                                                      self.emailField.textColor = [UIColor redColor];
                                                  }
                                                  
                                              }];
    }
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
                [self performSegueWithIdentifier:@"showSignUp" sender:self];
            else
                [self navigateToMainApp];
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
                [self performSegueWithIdentifier:@"showSignUp" sender:self];
            else
                [self navigateToMainApp];
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
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showSignUp"]) {
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

@end
