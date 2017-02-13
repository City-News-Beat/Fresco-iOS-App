//
//  FRSUsernameTableViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUsernameViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "FRSAlertView.h"
#import "FRSUserManager.h"
#import "NSString+Validation.h"
#import <UXCam/UXCam.h>

@interface FRSUsernameViewController () <UITextFieldDelegate, FRSAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) FRSAlertView *alert;
@property (strong, nonatomic) NSTimer *usernameTimer;
@property (nonatomic) BOOL usernameTaken;

@end

@implementation FRSUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"USERNAME";

    [self configureBackButtonAnimated:NO];
    [self hideSensitiveViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self stopUsernameTimer];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    if (self.passwordTextField.text.length > 0 && [self.usernameTextField.text isValidUsername] && !self.usernameTaken) {
        self.saveButton.enabled = YES;
        return YES;
    }

    if ([textField.text isEqualToString:@""] || textField.text == nil) {
        self.saveButton.enabled = NO;
        self.errorImageView.hidden = YES;
        self.errorImageView.image = [UIImage imageNamed:@"check-red"];
    }

    if ([self.usernameTextField.text isValidUsername]) {
        [self checkUsername];
    } else {
        self.saveButton.enabled = NO;
        self.errorImageView.image = [UIImage imageNamed:@"check-red"];
    }

    //Set max length to 40
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 40;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.view resignFirstResponder];
        if (self.passwordTextField.text.length > 0 && [self.usernameTextField.text isValidUsername] && !self.usernameTaken) {
            [self saveUsername:nil];
        }
    }

    return YES;
}

#pragma mark - Actions

- (IBAction)saveUsername:(id)sender {
    [self.view endEditing:YES];
    NSString *username = [self.usernameTextField.text stringByReplacingOccurrencesOfString:@"@" withString:@""];

    NSDictionary *digestion = @{ @"username" : username,
                                 @"verify_password" : self.passwordTextField.text };

    [[FRSUserManager sharedInstance] updateUserWithDigestion:digestion
                                                  completion:^(id responseObject, NSError *error) {
                                                    [[FRSUserManager sharedInstance] reloadUser];
                                                    if (!error) {
                                                        [self popViewController];
                                                        return;
                                                    }

                                                    if (error.code == -1009) {
                                                        if (!self.alert) {
                                                            self.alert = [[FRSAlertView alloc] initNoConnectionBannerWithBackButton:YES];
                                                            [self.alert show];
                                                        }
                                                        return;
                                                    }

                                                    NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                    NSInteger responseCode = response.statusCode;
                                                    if (responseCode == 403 || responseCode == 401) { //incorrect
                                                        [self showUsernameError];
                                                    } else {
                                                        [self presentGenericError];
                                                    }
                                                  }];

    FRSUser *userToUpdate = [[FRSUserManager sharedInstance] authenticatedUser];
    userToUpdate.username = username;
    [[[FRSUserManager sharedInstance] managedObjectContext] save:nil];
}

- (void)checkUsername {
    if (![self.usernameTextField.text isValidUsername]) {
        return;
    }

    NSRange whiteSpaceRange = [self.usernameTextField.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([self.usernameTextField.text isEqualToString:@""] || self.usernameTextField.text == nil || whiteSpaceRange.location != NSNotFound || [self.usernameTextField.text stringContainsEmoji]) {
        self.errorImageView.hidden = YES;
        return;
    }

    [self startUsernameTimer];
}

#pragma mark - Username Timer

- (void)startUsernameTimer {
    if (!self.usernameTimer) {
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(usernameTimerFired) userInfo:nil repeats:YES];
    }
}

- (void)stopUsernameTimer {
    if ([self.usernameTimer isValid]) {
        [self.usernameTimer invalidate];
    }

    self.usernameTimer = nil;
}

- (void)showUsernameError {
    self.errorImageView.hidden = NO;
    self.errorImageView.image = [UIImage imageNamed:@"check-red"];
}

- (void)showUsernameSuccess {
    self.errorImageView.hidden = NO;
    self.errorImageView.image = [UIImage imageNamed:@"check-green"];
}

- (void)usernameTimerFired {
    // Check for emoji and error
    if ([self.usernameTextField.text stringContainsEmoji]) {
        [self showUsernameError];
        return;
    }

    if ((![self.usernameTextField.text isEqualToString:@""])) {
        [[FRSUserManager sharedInstance] checkUsername:self.usernameTextField.text
                                            completion:^(id responseObject, NSError *error) {
                                              //Return if no internet
                                              if (error) {
                                                  if (error.code == -1009) {
                                                      if (!self.alert) {
                                                          self.alert = [[FRSAlertView alloc] initNoConnectionBannerWithBackButton:YES];
                                                          [self.alert show];
                                                      }
                                                      return;
                                                  }
                                                  [self showUsernameError];
                                                  self.usernameTaken = YES;
                                                  [self stopUsernameTimer];
                                              } else {
                                                  BOOL available = [responseObject[@"available"] boolValue];
                                                  if (available) {
                                                      [self showUsernameSuccess];
                                                      self.usernameTaken = NO;
                                                      [self stopUsernameTimer];
                                                  } else {
                                                      [self showUsernameError];
                                                      self.usernameTaken = YES;
                                                      [self stopUsernameTimer];
                                                  }
                                              }
                                            }];
    }
}

#pragma mark - FRSAlertView Delegate

- (void)didPressButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.passwordTextField];
}

@end
