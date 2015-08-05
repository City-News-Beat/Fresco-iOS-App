//
//  FirstRunAccountViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunAccountViewController.h"
#import "FRSDataManager.h"

@interface FirstRunAccountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@end

@implementation FirstRunAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, 700)];
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
    self.confirmPasswordField.returnKeyType = UIReturnKeyDone;
    
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
        [self.confirmPasswordField resignFirstResponder];
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

- (IBAction)clickedNext:(id)sender {

    if ([self.emailField.text length] && [self.passwordField.text length]) {
        
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


@end
