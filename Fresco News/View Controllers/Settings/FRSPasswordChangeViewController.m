
//
//  FRSPasswordChangeViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPasswordChangeViewController.h"
#import "UIColor+Fresco.h"
#import "FRSAlertView.h"
#import "FRSUserManager.h"
#import <UXCam/UXCam.h>
#import "FRSConnectivityAlertView.h"

@interface FRSPasswordChangeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *updatedPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) FRSConnectivityAlertView *alert;

@property (strong, nonatomic) UIImageView *errorImageView;

@property BOOL currentPasswordIsValid;
@property BOOL updatedPasswordIsValid;
@property BOOL updatedPasswordVerifyIsValid;

@end

@implementation FRSPasswordChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"PASSWORD";

    [self configureBackButtonAnimated:NO];

    self.oldPasswordTextField.delegate = self;
    self.updatedPasswordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    
    self.currentPasswordIsValid = NO;
    self.updatedPasswordIsValid = NO;
    self.updatedPasswordVerifyIsValid = NO;
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    //If passwords are invalid, do not continue
    if (![self isValidPassword:self.updatedPasswordTextField.text] || ![self isValidPassword:self.confirmPasswordTextField.text]) {
        self.saveButton.enabled = YES;
        return YES;
    }

    self.saveButton.enabled = NO;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.oldPasswordTextField) {
        [self.updatedPasswordTextField becomeFirstResponder];
    } else if (textField == self.updatedPasswordTextField) {
        [self.confirmPasswordTextField resignFirstResponder];
    } else {
        [self.view endEditing:YES];
    }

    return NO;
}

#pragma mark - Validators

- (BOOL)isValidPassword:(NSString *)password {
    if (password.length < 7) {
        return NO;
    }

    return YES;
}

#pragma mark - Actions

- (IBAction)savePassword:(id)sender {
    [self.view endEditing:YES];

    if ((![self.updatedPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text])) {
        self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"New passwords do not match." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
        [self.alert show];
        return;
    }

    NSDictionary *digestion = @{ @"verify_password" : self.oldPasswordTextField.text,
                                 @"password" : self.updatedPasswordTextField.text };

    [[FRSUserManager sharedInstance] updateUserWithDigestion:digestion
                                                  completion:^(id responseObject, NSError *error) {
                                                    [[FRSUserManager sharedInstance] reloadUser];

                                                    if (!error) {
                                                        [self popViewController];
                                                        return;
                                                    }

                                                    if (error) {
                                                        if (error.code == -1009) {
                                                            self.alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
                                                            [self.alert show];
                                                            return;
                                                        }

                                                        NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                        NSInteger responseCode = response.statusCode;

                                                        if (responseCode == 403 || responseCode == 401) {
                                                            if (!self.errorImageView) {
                                                                [self addErrorToView];
                                                                return;
                                                            }
                                                        } else {
                                                            // 500 level, server
                                                            [self presentGenericError];
                                                            return;
                                                        }
                                                    }
                                                  }];

    FRSUser *userToUpdate = [[FRSUserManager sharedInstance] authenticatedUser];
    userToUpdate.password = self.updatedPasswordTextField.text;
    [[[FRSUserManager sharedInstance] managedObjectContext] save:nil];
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.isSecureTextEntry) {
        if (self.errorImageView) {
            textField.text = 0;
            self.errorImageView.alpha = 0;
            self.errorImageView = nil;
            [self.errorImageView removeFromSuperview];
        }
    }
}

- (void)addErrorToView {
    if (!self.errorImageView) {
        self.errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.errorImageView.frame = CGRectMake(self.view.frame.size.width - 34, 10, 24, 24);
        self.errorImageView.alpha = 1; // 0 when animating
        [self.view addSubview:self.errorImageView];

        self.saveButton.enabled = NO;
    }
}

#pragma mark - FRSAlertView Delegate

- (void)didPressButton:(FRSAlertView *)alertView atIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    self.alert = nil;
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.confirmPasswordTextField];
    [UXCam occludeSensitiveView:self.updatedPasswordTextField];
}

@end
