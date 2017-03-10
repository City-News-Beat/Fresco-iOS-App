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
#import <UXCam/UXCam.h>

@interface FRSEmailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;

@property (strong, nonatomic) FRSAlertView *alert;

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

    [[FRSUserManager sharedInstance] updateUserWithDigestion:@{ @"email" : self.emailTextField.text,
                                                                @"verify_password" : self.passwordTextField.text }
        completion:^(id responseObject, NSError *error) {
          [[FRSUserManager sharedInstance] reloadUser];

          if (!error && responseObject) {
              FRSUser *userToUpdate = [[FRSUserManager sharedInstance] authenticatedUser];
              userToUpdate.email = self.emailTextField.text;
              [[[FRSUserManager sharedInstance] managedObjectContext] save:Nil];

              [self popViewController];
              return;
          }

          if (error.code == -1009) {
              if (!self.alert) {
                  if (!self.alert) {
                      self.alert = [[FRSAlertView alloc] initNoConnectionBannerWithBackButton:YES];
                      [self.alert show];
                  }
              }
              return;
          }

          NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
          NSInteger responseCode = response.statusCode;
          NSLog(@"Update User Error: %ld", (long)responseCode);

          if (responseCode == 403 || responseCode == 401) {
              self.errorImageView.hidden = NO;
              self.saveButton.enabled = NO;
          } else if (responseCode == 400) {
              self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"An account already exists with this email. Would you like to log in?" actionTitle:@"CANCEL" cancelTitle:@"LOGIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
              [self.alert show];
          } else {
              self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to reach server. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
              [self.alert show];
          }
        }];
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

#pragma mark - FRSAlertView Delegate

- (void)didPressButton:(FRSAlertView *)alertView atIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.passwordTextField];
}

@end
