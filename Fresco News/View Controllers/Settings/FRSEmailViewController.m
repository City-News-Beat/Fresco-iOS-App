//
//  FRSEmailViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSEmailViewController.h"
#import "UIColor+Fresco.h"
#import "FRSUserManager.h"
#import "NSString+Validation.h"
#import "FRSConnectivityAlertView.h"
#import "NSError+Fresco.h"
#import <UXCam/UXCam.h>

@interface FRSEmailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;

@end

@implementation FRSEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"EMAIL ADDRESS";

    [self configureBackButtonAnimated:NO];
    [self hideSensitiveViews];
}

#pragma mark - Actions

- (IBAction)saveEmail:(id)sender {
    if (self.passwordTextField.text.length == 0 || ![self.emailTextField.text isValidEmail]) {
        return;
    }

    [self.view endEditing:YES];

    void (^handleResponse)(id, NSError*) = ^void(id responseObject, NSError *error) {
        if (!error && responseObject) {
            [[FRSUserManager sharedInstance] reloadUser];
            [self popViewController];
            return;
        } else if (error.code == -1009) {
            FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionBannerWithBackButton:YES];
            [alert show];
            return;
        }
        
        NSDictionary *errorResponse = [error errorDictionaryFromAPIError];
        NSString *errorString = errorResponse[@"error"][@"msg"];
        
        if([errorString containsString:@"Invalid password"]) {
            errorString = @"The password you've entered is incorrect! Please try again.";
        }
        
        FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initWithTitle:@"ERROR" message:errorString actionTitle:@"" cancelTitle:@"OK" cancelTitleColor:nil delegate:nil];
        [alert show];
    };
    
    [[FRSUserManager sharedInstance] updateUserWithDigestion:@{ @"email" : self.emailTextField.text,
                                                                @"verify_password" : self.passwordTextField.text }
                                                  completion:handleResponse];
    
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        textField.text = 0;
        self.errorImageView.hidden = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    if ([self.passwordTextField.text isValidPassword] && [self.emailTextField.text isValidEmail]) {
        self.saveButton.enabled = YES;
    } else {
        self.saveButton.enabled = NO;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.view resignFirstResponder];
        [self saveEmail:nil];
    }

    return YES;
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.passwordTextField];
}

@end
