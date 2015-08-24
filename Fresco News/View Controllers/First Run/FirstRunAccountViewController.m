//
//  FirstRunAccountViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunAccountViewController.h"
#import "FirstRunTOSViewController.h"
#import "FRSDataManager.h"
#import "NSString+Validation.h"

typedef enum : NSUInteger {
    LoginFresco,
    LoginFacebook,
    LoginTwitter
} LoginType;

@interface FirstRunAccountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@property (assign, nonatomic) BOOL signUpRunning;

@end

@implementation FirstRunAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, 700)];
    self.facebookButton.layer.cornerRadius = 4;
    self.twitterButton.layer.cornerRadius = 4;
    
    self.signUpRunning = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // we may prepopulate these either during pushing or backing
    if (self.email)
        self.emailField.text = self.email;
    
    if (self.password)
        self.passwordField.text = self.password;

    self.emailField.returnKeyType = UIReturnKeyNext;
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.confirmPasswordField.returnKeyType = UIReturnKeyGo;
    
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

#pragma mark - UI Actions

- (IBAction)clickedNext:(id)sender {
    
    [self hitNext];
}
- (IBAction)facebookButtonTapped:(id)sender {
    
     [self performLogin:LoginFacebook button:self.facebookButton];
}

- (IBAction)twitterButtonTapped:(id)sender {
    
     [self performLogin:LoginTwitter button:self.twitterButton];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self.confirmPasswordField becomeFirstResponder];
    }else if (textField == self.confirmPasswordField) {
        [self.confirmPasswordField resignFirstResponder];
        [self hitNext];  
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
                                height = -5.8 * self.confirmPasswordField.frame.size.height;
                            }
                            
                            self.topVerticalSpaceConstraint.constant = height;
                            self.bottomVerticalSpaceConstraint.constant = -1 * height;
                            [self.view layoutIfNeeded];
                        } completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.emailField isFirstResponder] && [touch view] != self.emailField) {
        [self.emailField resignFirstResponder];
    }
    
    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    
    if ([self.confirmPasswordField isFirstResponder] && [touch view] != self.confirmPasswordField) {
        [self.confirmPasswordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Sign up / Login Methods

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
            if(view != button && view.tag!= 51 && view.tag != 50)
                view.alpha = .26f;
        }
        
    }];
    
    if(login == LoginFacebook){
        
        //Facebook icon image
        [self.view viewWithTag:51].hidden = YES;
        
        [[FRSDataManager sharedManager] loginViaFacebookWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if (user) {
                
                [self transferUser];
                
            }
            else {
                
                //TODO: check if these are the strings we want
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:FACEBOOK_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:nil];
                
                [button setTitle:FACEBOOK forState:UIControlStateNormal];
                
                [self revertScreenToNormal];
            }
            
        }];
        
    }
    else if(login == LoginTwitter){
        
        //Twitter icon image
        [self.view viewWithTag:50].hidden = YES;
        
        [[FRSDataManager sharedManager] loginViaTwitterWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if (user) {
                
                [self transferUser];
                
            }
            else {
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:TWITTER_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:nil];
                
                [self revertScreenToNormal];
                
                [button setTitle:TWITTER forState:UIControlStateNormal];
                
                NSLog(@"%@", error);
                
            }
        }];
        
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

- (void)hitNext{
    
    if(_signUpRunning) return;
    
    _signUpRunning = YES;
    
    if (![self.emailField.text isValidEmail]){
    
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:@"Invalid Email"
                                     message:@"Please enter a valid email" action:DISMISS]
                           animated:YES
                         completion:nil];
        
        _signUpRunning = NO;
        
        return;
    
    }
    else if(![self.passwordField.text isValidPassword]){
    
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:@"Invalid Password"
                                     message:@"Please enter a password that is 6 characters or longer" action:DISMISS]
                           animated:YES
                         completion:nil];

        _signUpRunning = NO;
        
        return;

    }
    //Both fields valid
    
    // save this to allow backing to the VC
    self.email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *confirmPassword = [self.confirmPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![self.password isEqualToString:confirmPassword]) {
        
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:ERROR
                                     message:PASSWORD_ERROR_TITLE action:DISMISS]
                           animated:YES
                         completion:nil];
    }
    else {
        
        [[FRSDataManager sharedManager] signupUser:self.email email:self.email password:self.password block:^(BOOL succeeded, NSError *error) {
            
            //Failed signup
            if (error || !succeeded) {
                
                 [self presentViewController:[[FRSAlertViewManager sharedManager]
                                              alertControllerWithTitle:ERROR
                                              message:SIGNUP_ERROR action:STR_TRY_AGAIN]
                                    animated:YES
                                  completion:nil];
                 
                 self.emailField.textColor = [UIColor redColor];
             
            }
            //Successfully signed up
            else {

                 [self transferUser];
                
            }
            
            _signUpRunning = NO;
            
         }];
    }

}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEG_REPLACE_WITH_TOS]) {
        FirstRunTOSViewController *tosVC = [segue destinationViewController];
        tosVC.updatedTerms = YES;
    }
}

@end