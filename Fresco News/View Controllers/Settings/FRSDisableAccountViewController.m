//
//  FRSDisableAccountViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDisableAccountViewController.h"
#import "FRSAlertView.h"
#import "EndpointManager.h"
#import "FRSUserManager.h"
#import "FRSConnectivityAlertView.h"
#import <UXCam/UXCam.h>
#import "NSString+Validation.h"

@interface FRSDisableAccountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *usernameErrorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailErrorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordErrorImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *disableButton;

@end

@implementation FRSDisableAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"DISABLE MY ACCOUNT";
    [self configureBackButtonAnimated:NO];
    [self hideSensitiveViews:self.passwordTextField];
}

#pragma mark - Actions

- (void)disableAccount {
    //These checks should return when the API responds in the block below
    if (![[[FRSUserManager sharedInstance].authenticatedUser.username lowercaseString] isEqualToString:[self.usernameTextField.text lowercaseString]]) {
        return;
    }

    if (![[[FRSUserManager sharedInstance].authenticatedUser.email lowercaseString] isEqualToString:[self.emailTextField.text lowercaseString]]) {
        return;
    }

    [[FRSUserManager sharedInstance] disableAccountWithDigestion:@{ @"password" : self.passwordTextField.text,
                                                                    @"email" : self.emailTextField.text,
                                                                    @"username" : self.usernameTextField.text }
        completion:^(id responseObject, NSError *error) {

          NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
          NSInteger responseCode = response.statusCode;
          NSLog(@"Disable Account Error: %ld", (long)responseCode);

          if (error.code == -1009) {
              FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionBannerWithBackButton:YES];
              [alert show];
              return;
          }

          if (responseCode == 403 || responseCode == 401) {
              [self presentGenericError];
          } else {
              [self logout];
          }
        }];
}

- (void)logout {
    [[[FRSUserManager sharedInstance] managedObjectContext] deleteObject:[FRSUserManager sharedInstance].authenticatedUser];
    [[[FRSUserManager sharedInstance] managedObjectContext] save:nil];
    [SAMKeychain deletePasswordForService:serviceName account:[EndpointManager sharedInstance].currentEndpoint.frescoClientId];

    [NSUserDefaults resetStandardUserDefaults];

    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"facebook-name"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebook-connected"];

    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"twitter-handle"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:settingsUserNotificationRadius];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:settingsUserNotificationToggle];

    [self popViewController];

    [self.tabBarController setSelectedIndex:0];
}

#pragma mark - UITextField Deleagte

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    if ([self.usernameTextField.text isValidUsername] && ![self.usernameTextField.text stringContainsEmoji] && [self.emailTextField.text isValidEmail] && self.passwordTextField.text.length > 0) {
        self.disableButton.enabled = YES;
    } else {
        self.disableButton.enabled = NO;
    }

    return YES;
}

#pragma mark - UXCam

- (void)hideSensitiveViews:(UIView *)view {
    [UXCam occludeSensitiveView:view];
}

@end
