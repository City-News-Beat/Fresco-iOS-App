//
//  FirstRunAccountViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunAccountViewController.h"
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
- (IBAction)twitterButtonTapped:(id)sender;

- (IBAction)facebookButtonTapped:(id)sender;

@end

@implementation FirstRunAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, 700)];
    self.facebookButton.layer.cornerRadius = 4;
    self.twitterButton.layer.cornerRadius = 4;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    // we may prepopulate these either during pushing or backing
    if (self.email)
        self.emailField.text = self.email;
    
    if (self.password)
        self.passwordField.text = self.password;
    
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmPasswordField.delegate = self;

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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self.confirmPasswordField becomeFirstResponder];
    }else if (textField == self.confirmPasswordField) {
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

- (void)performLogin:(LoginType)login button:(UIButton *)button{
    
    self.view.userInteractionEnabled = NO;
    
    [button setTitle:@"" forState:UIControlStateNormal];
    
    CGRect spinnerFrame = (IS_IPHONE_5) ? CGRectMake(button.frame.size.width/2.2, button.frame.size.height/4, 20, 20) : CGRectMake(button.frame.size.width  / 2 - 7, 13, 20, 20);
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
    
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
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:INVALID_CREDENTIALS action:nil]
                                   animated:YES completion:nil];
                
                
                [button setTitle:LOGIN forState:UIControlStateNormal];
                
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
                //TODO: check if these are the strings we want
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:TWITTER_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:nil];
                
                [button setTitle:FACEBOOK forState:UIControlStateNormal];
                
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

- (void)transferUser{
    
    if ([PFUser currentUser].isNew || ![[FRSDataManager sharedManager] currentUserValid]){
        [self performSegueWithIdentifier:SEG_REPLACE_WITH_SIGNUP sender:self];
    }
    else
        [self navigateToMainApp];
}

- (void)revertScreenToNormal{
    
    self.view.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.spinner.alpha = 0;
        
        for (UIView *view in [self.view subviews]) view.alpha = 1;
        
    }];
    
}

- (IBAction)clickedNext:(id)sender {

    [self hitNext];
}

- (void)hitNext {
    if ([self.emailField.text isValidEmail] &&
        [self.passwordField.text isValidPassword]) {
        
        // save this to allow backing to the VC
        self.email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *confirmPassword = [self.confirmPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (![self.password isEqualToString:confirmPassword]) {
            [self
             presentViewController:[[FRSAlertViewManager sharedManager]
                                    alertControllerWithTitle:ERROR
                                    message:FB_LOGOUT_PROMPT action:DISMISS]
             animated:YES
             completion:nil];
        }
        else {
            [[FRSDataManager sharedManager]
             signupUser:self.email
             email:self.email
             password:self.password
             block:^(BOOL succeeded, NSError *error) {
                 
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR
                                                                     message:[error.userInfo objectForKey:@"error"]
                                                                    delegate: self
                                                           cancelButtonTitle: CANCEL
                                                           otherButtonTitles:nil, nil];
                     [alert addButtonWithTitle:STR_TRY_AGAIN];
                     [alert show];
                     
                     self.emailField.textColor = [UIColor redColor];
                 } else {
                     
                     [self performSegueWithIdentifier:SEG_SHOW_PERSONAL_INFO sender:self];
                 }
                 
             }];
        }
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
    
    if ([self.confirmPasswordField isFirstResponder] && [touch view] != self.confirmPasswordField) {
        [self.confirmPasswordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


- (IBAction)twitterButtonTapped:(id)sender {
    [self performLogin:LoginTwitter button:self.twitterButton];
}

- (IBAction)facebookButtonTapped:(id)sender {
    [self performLogin:LoginFacebook button:self.facebookButton];
}
@end
