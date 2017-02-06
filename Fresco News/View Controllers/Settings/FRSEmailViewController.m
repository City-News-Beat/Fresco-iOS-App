//
//  FRSEmailViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSEmailViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "FRSUserManager.h"
#import "NSString+Validation.h"
#import <UXCam/UXCam.h>

@interface FRSEmailViewController ()

@property (strong, nonatomic) FRSAlertView *alert;
@property (strong, nonatomic) UIImageView *errorImageView;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property BOOL emailIsValid;
@property BOOL passwordIsValid;

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

    if (!self.emailIsValid || !self.passwordIsValid) {
        return;
    }

    [self.view endEditing:YES];

    [[FRSUserManager sharedInstance] updateUserWithDigestion:@{ @"email" : self.email,
                                                                @"verify_password" : self.password }
        completion:^(id responseObject, NSError *error) {
          [[FRSUserManager sharedInstance] reloadUser];

          if (!error && responseObject) {
              FRSUser *userToUpdate = [[FRSUserManager sharedInstance] authenticatedUser];
              userToUpdate.email = self.email;
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
              if (!self.errorImageView) {
                  [self addErrorToView];
              }

          } else if (responseCode == 400) {
              self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"An account already exists with this email. Would you like to log in?" actionTitle:@"CANCEL" cancelTitle:@"LOGIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
              [self.alert show];

          } else {
              self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to reach server. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
              [self.alert show];
          }
          return;
        }];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
        self.errorImageView.frame = CGRectMake(self.view.frame.size.width - 34, 55, 24, 24);
        self.errorImageView.alpha = 1; // 0 when animating
        [self.view addSubview:self.errorImageView];

        [self.saveButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.saveButton.userInteractionEnabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    if (textField.isSecureTextEntry) {
        //User is editing password textField
        self.password = textField.text;
        if ([self.password isValidPassword]) {
            self.passwordIsValid = YES;
        } else {
            self.passwordIsValid = NO;
        }

    } else {
        //User is editing email textField
        self.email = textField.text;
        if ([self.email isValidEmail]) {
            self.emailIsValid = YES;
        } else {
            self.emailIsValid = NO;
        }
    }

    if (self.emailIsValid && self.passwordIsValid) {

        [self.saveButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.saveButton.userInteractionEnabled = YES;
    } else {
        [self.saveButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.saveButton.userInteractionEnabled = NO;
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

- (void)didPressButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - UXCam

-(void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.passwordTextField];
}


@end
