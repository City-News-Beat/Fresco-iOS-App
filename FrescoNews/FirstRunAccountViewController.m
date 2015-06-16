//
//  FirstRunAccountViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunAccountViewController.h"
#import "FRSDataManager.h"

@interface FirstRunAccountViewController ()
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@end

@implementation FirstRunAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self styleButtons];
    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, 700)];
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

- (void)styleButtons
{
    self.twitterButton.layer.cornerRadius = 8;
    self.twitterButton.clipsToBounds = YES;
    
    self.facebookButton.layer.cornerRadius = 8;
    self.facebookButton.clipsToBounds = YES;
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
    [self performSegueWithIdentifier:@"showPersonalInfo" sender:self];
//    if ([self.emailField.text length] != 0 && [self.passwordField.text length] != 0) {
//        
//        [[FRSDataManager sharedManager] signupUser:self.emailField.text
//                                             email:self.emailField.text
//                                          password:self.passwordField.text
//                                             block:^(BOOL succeeded, NSError *error) {
//                                                 if (error) {
//                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                                                     message:[error.userInfo objectForKey:@"error"]
//                                                                                                    delegate: self
//                                                                                           cancelButtonTitle: @"Cancel"
//                                                                                           otherButtonTitles:nil, nil];
//                                                     [alert addButtonWithTitle:@"Try Again"];
//                                                     [alert show];
//                                                     
//                                                     self.emailField.textColor = [UIColor redColor];
//                                                 }
//                                                 else{
//                                                     [self performSegueWithIdentifier:@"showPersonalInfo" sender:self];
//                                                 }
//                                                 
//                                             }];
//    }
//    
    
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
