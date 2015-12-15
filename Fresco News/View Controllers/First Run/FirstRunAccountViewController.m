//
//  FirstRunAccountViewController.m
//  FrescoNews
//
//  Created by Fresco News 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunAccountViewController.h"
#import "FirstRunPageViewController.h"
#import "TOSViewController.h"
#import "FRSDataManager.h"
#import "NSString+Validation.h"
#import "FRSSocialButton.h"
#import "FRSBackButton.h"
#import "UIView+Helpers.h"

@interface FirstRunAccountViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet FRSSocialButton *facebookButton;

@property (weak, nonatomic) IBOutlet FRSSocialButton *twitterButton;

@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;

@property (weak, nonatomic) IBOutlet UITextView *tosTextView;

@property (assign, nonatomic) BOOL signUpRunning;

@end

@implementation FirstRunAccountViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.signUpRunning = NO;
    
    self.tosTextView.delegate = self;
    
    [self.facebookButton setUpSocialIcon:SocialNetworkFacebook withRadius:YES];
    [self.twitterButton setUpSocialIcon:SocialNetworkTwitter withRadius:YES];
    
    self.parentViewController.view.backgroundColor = [UIColor frescoGreyBackgroundColor];
    
    [self setupTerms];
    [self.fieldsWrapper addBorderWithWidth:1.0f];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.email = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_EMAIL_TEMP"];
    self.password = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_PASSWORD_TEMP"];
    //we may prepopulate these either during pushing or backing
    if (self.email) {
        self.emailField.text = self.email;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_EMAIL_TEMP"];
    }
    
    if (self.password) {
        self.passwordField.text = self.password;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_PASSWORD_TEMP"];
    }

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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}



#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    TOSViewController *tosVC = [TOSViewController new];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tosVC];
    
    [self presentViewController:navigationController animated:YES completion:nil];
          
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailField)
        [self.passwordField becomeFirstResponder];
    
    else if (textField == self.passwordField)
        [self.confirmPasswordField becomeFirstResponder];
   
    else if (textField == self.confirmPasswordField){
        [self.confirmPasswordField resignFirstResponder];
        [self processLogin];  
    }
    
    return NO;
}


- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    CGSize kbSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect viewFrame = self.parentViewController.parentViewController.view.frame;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
        viewFrame.origin.y = -kbSize.height;
    else if([notification.name isEqualToString:UIKeyboardWillHideNotification])
        viewFrame.origin.y = 0;
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            
                            self.parentViewController.parentViewController.view.frame= viewFrame;
                            
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

- (void)setupTerms {
    
    NSString *termsOfService = @"Terms of Service";
    
    NSString *signupTerms = [NSString stringWithFormat:@"By signing up, you agree to the %@", termsOfService];
    
    NSMutableAttributedString *terms = [[NSMutableAttributedString alloc] initWithString:signupTerms];
    
    NSRange range = NSMakeRange([signupTerms length] - [termsOfService length], [termsOfService length]);
    
    [terms addAttribute:NSLinkAttributeName value:@"https://www.fresconews.com/terms" range:range];
    
    [terms addAttribute:NSForegroundColorAttributeName value:[UIColor frescoBlueColor] range:range];
    [terms addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.54] range:NSMakeRange(0, [signupTerms length] - [termsOfService length])];
    
    self.tosTextView.attributedText = terms;
    self.tosTextView.textAlignment = NSTextAlignmentCenter;
}

- (void)processLogin {

    if (![self.emailField.text isValidEmail]){
    
        [self presentViewController:[FRSAlertViewManager
                                     alertControllerWithTitle:@"Invalid Email"
                                     message:@"Please enter a valid email" action:DISMISS]
                           animated:YES
                         completion:^{
                             [self enableNextButton];
                         }];
        
        return;
    
    }
    else if(![self.passwordField.text isValidPassword]){
    
        [self presentViewController:[FRSAlertViewManager
                                     alertControllerWithTitle:@"Invalid Password"
                                     message:@"Please enter a password that is 6 characters or longer" action:DISMISS]
                           animated:YES
                         completion:^{
                             [self enableNextButton];
                         }];
        
        return;

    }
    //Both fields valid
    
    // save this to allow backing to the VC
    
    NSString *rawEmail = self.emailField.text;
    
    NSArray *comps = [rawEmail componentsSeparatedByString:@"@"];
    NSString *namePart;
    NSString *addressPart;
    
    if (comps.count > 1){
        namePart = comps[0];
        addressPart = comps[1];
    }
    
    NSArray *plusComps = [namePart componentsSeparatedByString:@"+"];
    namePart = plusComps[0];
    
    namePart = [namePart stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *strippedEmail = [[NSString stringWithFormat:@"%@@%@", namePart, addressPart] lowercaseString];
    
    self.email = strippedEmail;
    
    self.password = self.passwordField.text;
    
    NSString *confirmPassword = self.confirmPasswordField.text;
    
    if (![self.password isEqualToString:confirmPassword]) {
        
        [self presentViewController:[FRSAlertViewManager
                                     alertControllerWithTitle:ERROR
                                     message:PASSWORD_ERROR_TITLE action:DISMISS]
                           animated:YES
                         completion:^{
                             [self enableNextButton];
                         }];

    }
    else {
        
        [[FRSDataManager sharedManager] signupUser:self.email email:self.email password:self.password block:^(BOOL succeeded, NSError *error) {
            
            //Failed signup
            if (error || !succeeded) {
                
                NSString *errorResponse;
                
                if(error.code == 202)
                    errorResponse = SIGNUP_EXISTS;
                else
                    errorResponse = SIGNUP_ERROR;
                
                [self presentViewController:[FRSAlertViewManager
                                                 alertControllerWithTitle:ERROR
                                                 message:errorResponse action:STR_TRY_AGAIN]
                                       animated:YES
                                     completion:nil];
                
                self.emailField.textColor = [UIColor redColor];
             
            }
            //Successfully signed up
            else {

                [self navigateToNextIndex];
                
            }
            
            [self enableNextButton];
            
         }];
    }
}


- (IBAction)facebookLogin:(id)sender{
    [self performLogin:LoginFacebook button:self.facebookButton withLoginInfo:nil];
}

- (IBAction)twitterLogin:(id)sender {
    
    [self performLogin:LoginTwitter button:self.twitterButton withLoginInfo:nil];
    
}


@end