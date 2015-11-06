//
//  FirstRunViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/24/15.
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
#import "UIView+Border.h"
#import "FirstRunPageViewController.h"
#import "FRSSocialButton.h"

@interface FirstRunViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

@property (weak, nonatomic) IBOutlet FRSSocialButton *twitterButton;
@property (weak, nonatomic) IBOutlet FRSSocialButton *facebookButton;
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
    
    [self.fieldsWrapper addBorderWithWidth:1.0f];
    
    [self.twitterButton setUpSocialIcon:SocialNetworkTwitter withRadius:YES];
    [self.facebookButton setUpSocialIcon:SocialNetworkFacebook withRadius:YES];

    // Add shadow above Dismiss Button
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dismissButton.frame.size.width, 1)];
    shadowView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.08];
    [self.dismissButton addSubview:shadowView];
    
    //Set return buttons
    self.emailField.returnKeyType = UIReturnKeyNext;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    

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

- (void)viewWillDisappear:(BOOL)animated{
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
            
            [self navigateToNextIndex];
            
        }
        else {
            [self loginButtonAction:self];
        }
    }
    
    return NO;
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    
    CGSize kbSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect viewFrame = self.parentViewController.parentViewController.view.frame;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
        viewFrame.origin.y = -kbSize.height /2;
    else if([notification.name isEqualToString:UIKeyboardWillHideNotification])
        viewFrame.origin.y = 0;
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                        
                            self.parentViewController.parentViewController.view.frame = viewFrame;
                            
                        } completion:nil];
}


#pragma mark - IBAction Listeners

/*
** Login
*/

- (IBAction)loginButtonAction:(id)sender {
    
    //Check fields first
    if([self.emailField.text isValidEmail]){
    
        [self performLogin:LoginFresco button:self.loginButton
             withLoginInfo:@{@"email" : self.emailField.text,
                             @"password" : self.passwordField.text
                             }];
    
    }
    else {
        
        [self presentViewController:[FRSAlertViewManager
                                     alertControllerWithTitle:LOGIN_ERROR
                                     message:LOGIN_PROMPT action:nil]
                                       animated:YES completion:nil];
    
    }

}

/**
 *  Signup Button Action
 *
 *  @param sender <#sender description#>
 */

- (IBAction)signUpButtonAction:(id)sender
{
    self.email = self.emailField.text;
    self.password = self.passwordField.text;
    
    [self navigateToNextIndex];
    
}
- (IBAction)twitterAction:(id)sender {
    
    [self performLogin:LoginTwitter button:sender withLoginInfo:nil];

}
- (IBAction)facebookAction:(id)sender {
    [self performLogin:LoginFacebook button:sender withLoginInfo:nil];

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

@end
