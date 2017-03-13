//
//  FRSNewPasswordAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSNewPasswordAlertView.h"
#import "FRSUserManager.h"
#import "FRSAuthManager.h"
#import "FRSConnectivityAlertView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "UIFont+Fresco.h"
#import "NSString+Validation.h"

@interface FRSNewPasswordAlertView () <UITextFieldDelegate>

@property (strong, nonatomic) UIView *actionLine;

@property (strong, nonatomic) UIButton *expandTOSButton;
@property (strong, nonatomic) UITextView *TOSTextView;
@property (strong, nonatomic) UIView *topLine;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@property (strong, nonatomic) UIImageView *usernameCheckIV;
@property (strong, nonatomic) UILabel *usernameTakenLabel;
@property BOOL migrationAlertShouldShowPassword;

@property (strong, nonatomic) UIImageView *emailCheckIV;

@property (nonatomic) BOOL usernameTaken;
@property (nonatomic) BOOL emailTaken;
@property (strong, nonatomic) NSTimer *usernameTimer;

@end

@implementation FRSNewPasswordAlertView

- (instancetype)initNewStuffWithPasswordField:(BOOL)password {
    self = [super init];
    if (self) {
        
        BOOL userHasEmail;
        BOOL userHasUsername;
        BOOL userHasPassword = !password;
        
        if ([[[[FRSUserManager sharedInstance] authenticatedUser] username] isEqual:[NSNull null]] || [[[[FRSUserManager sharedInstance] authenticatedUser] username] isEqualToString:@""] || ![[[FRSUserManager sharedInstance] authenticatedUser] username]) {
            userHasUsername = NO;
        } else {
            userHasUsername = YES;
        }
        
        if ([[[[FRSUserManager sharedInstance] authenticatedUser] email] isEqual:[NSNull null]] || [[[[FRSUserManager sharedInstance] authenticatedUser] email] isEqualToString:@""] || ![[[FRSUserManager sharedInstance] authenticatedUser] email]) {
            userHasEmail = NO;
        } else {
            userHasEmail = YES;
        }
        
        self.height = 0;
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        [self configureDarkOverlay];
        
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"NEW STUFF!";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.text = [NSString stringWithFormat:@"We’ve added a ton of new\nfeatures for Fresco 3.0. You can now %@, %@, and %@ on galleries, %@ your friends and favorite photographers, and see more about assignments.\n\nTo start, we’ll need you to choose a username. You’ll be able to change it later on.", @"like", @"repost", @"comment", @"follow"];
        NSRange range1 = [self.messageLabel.text rangeOfString:@"like"];
        NSRange range2 = [self.messageLabel.text rangeOfString:@"repost"];
        NSRange range3 = [self.messageLabel.text rangeOfString:@"comment"];
        NSRange range4 = [self.messageLabel.text rangeOfString:@"follow"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.messageLabel.text];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range1];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range2];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range3];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range4];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:attributedText.string];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedText.string length])];
        
        self.messageLabel.attributedText = attributedText;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 336, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];
        
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(16, 337, 54, 44);
        [self.actionButton setTitleColor:[UIColor frescoRedColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 37, 44);
        [self.cancelButton addTarget:self action:@selector(updateUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"DONE" forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];
        
        UIView *usernameContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 248, self.frame.size.width, 44)];
        [self addSubview:usernameContainer];
        UIView *usernameTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        usernameTopLine.backgroundColor = [UIColor frescoShadowColor];
        [usernameContainer addSubview:usernameTopLine];
        UIView *emailContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44)];
        [self addSubview:emailContainer];
        UIView *emailTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        emailTopLine.backgroundColor = [UIColor frescoShadowColor];
        [emailContainer addSubview:emailTopLine];
        
        self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16 + 16), 20)];
        [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.usernameTextField.tag = 1;
        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usernameTextField.placeholder = @"@username";
        self.usernameTextField.tintColor = [UIColor frescoBlueColor];
        self.usernameTextField.delegate = self;
        self.usernameTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.usernameTextField.textColor = [UIColor frescoDarkTextColor];
        self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [usernameContainer addSubview:self.usernameTextField];
        
        self.usernameCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.usernameCheckIV.frame = CGRectMake(usernameContainer.frame.size.width - 24 - 6, 10, 24, 24);
        self.usernameCheckIV.alpha = 0;
        [usernameContainer addSubview:self.usernameCheckIV];
        
        self.usernameTakenLabel = [[UILabel alloc] initWithFrame:CGRectMake(-44 - 6, 5, 44, 17)];
        self.usernameTakenLabel.text = @"TAKEN";
        self.usernameTakenLabel.alpha = 0;
        self.usernameTakenLabel.textColor = [UIColor frescoRedColor];
        self.usernameTakenLabel.font = [UIFont notaBoldWithSize:15];
        [self.usernameCheckIV addSubview:self.usernameTakenLabel];
        
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16 + 16), 20)];
        [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.emailTextField.tag = 2;
        self.emailTextField.placeholder = @"Email address";
        self.emailTextField.tintColor = [UIColor frescoBlueColor];
        self.emailTextField.delegate = self;
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.textColor = [UIColor frescoDarkTextColor];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        [emailContainer addSubview:self.emailTextField];
        
        self.emailCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.emailCheckIV.frame = CGRectMake(emailContainer.frame.size.width - 24 - 6, 10, 24, 24);
        self.emailCheckIV.alpha = 0;
        [emailContainer addSubview:self.emailCheckIV];
        
        if (userHasEmail) {
            emailContainer.alpha = 0;
            self.height -= 44;
            self.emailTextField = nil;
            [self.emailTextField removeFromSuperview];
        }
        
        if (userHasUsername) {
            usernameContainer.alpha = 0;
            self.height -= 44;
            self.usernameTextField = nil;
            [self.usernameTextField removeFromSuperview];
        }
        
        UIView *passwordContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44)];
        if (!userHasPassword) {
            self.migrationAlertShouldShowPassword = YES;
            self.height += 44;
            [self addSubview:passwordContainer];
            
            UIView *passwordTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
            passwordTopLine.backgroundColor = [UIColor frescoShadowColor];
            [passwordContainer addSubview:passwordTopLine];
            
            self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16 + 16), 20)];
            [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            self.passwordTextField.tag = 3;
            if ([[FRSAuthManager sharedInstance] socialUsed]) {
                self.passwordTextField.placeholder = @"Set a New Password";
            } else {
                self.passwordTextField.placeholder = @"Confirm Password";
            }
            self.passwordTextField.tintColor = [UIColor frescoBlueColor];
            self.passwordTextField.delegate = self;
            self.passwordTextField.keyboardType = UIKeyboardTypeDefault;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.textColor = [UIColor frescoDarkTextColor];
            self.passwordTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            [passwordContainer addSubview:self.passwordTextField];
            
            if (emailContainer.alpha == 0) {
                passwordContainer.transform = CGAffineTransformMakeTranslation(0, -44);
            }
        }
        
        self.dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.dismissKeyboardTap];
        
        self.height += 380;
        
        NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
        NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;
        
        self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, self.height - 44, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
        self.actionButton.frame = CGRectMake(self.actionButton.frame.origin.x, self.height - 44, self.actionButton.frame.size.width, self.actionButton.frame.size.height);
        line.frame = CGRectMake(line.frame.origin.x, self.height - 44, line.frame.size.width, line.frame.size.height);
        self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
        
        [self addShadowAndClip];
        
        [self animateIn];
        
        //Only updating username
        if (userHasPassword && userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            
            return self;
        }
        
        //Only updaing email
        if (userHasPassword && !userHasEmail && userHasUsername) {
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
        
        //Only updating password
        if (!userHasPassword && userHasEmail && userHasUsername) {
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
        
        //Updating password and username
        if (!userHasPassword && userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
        
        //Updating password and email
        if (!userHasPassword && !userHasEmail && userHasUsername) {
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
        
        //Updating username and email
        if (userHasPassword && !userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
        
        //Updaing username, email, and password
        if (!userHasPassword && !userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 4, self.frame.size.width, 44);
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
    }
    return self;
}

- (void)logoutTapped {
    [self.delegate logoutAlertAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout_notification" object:nil];
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.dismissKeyboardTap];
    [self dismiss];
}

- (void)updateUserInfo {
    [self checkEmail];
    
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.dismissKeyboardTap];
    
    NSMutableDictionary *digestion = [[NSMutableDictionary alloc] init];
    
    NSString *username = [self.usernameTextField.text stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (email != nil) {
        [digestion setObject:email forKey:@"email"];
    }
    
    if (username != nil) {
        [digestion setObject:username forKey:@"username"];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"twitter-connected"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"needs-password"]) {
        [digestion setObject:password forKey:@"password"];
    }
    
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    
    self.cancelButton.alpha = 0;
    spinner.frame = CGRectMake(self.frame.size.width - 20 - 10, self.frame.size.height - 20 - 10, 20, 20);
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [self addSubview:spinner];
    
    [[FRSUserManager sharedInstance] updateLegacyUserWithDigestion:digestion
                                                        completion:^(id responseObject, NSError *error) {
                                                            [[FRSUserManager sharedInstance] saveUserFields:responseObject];
                                                            
                                                            if (responseObject && !error) {
                                                                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:userNeedsToMigrate];
                                                                [[NSUserDefaults standardUserDefaults] setBool:true forKey:userHasFinishedMigrating];
                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                            }
                                                            
                                                            spinner.alpha = 0;
                                                            [spinner stopLoading];
                                                            [spinner removeFromSuperview];
                                                            self.cancelButton.alpha = 1;
                                                            
                                                            if (error) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [spinner stopLoading];
                                                                    [spinner removeFromSuperview];
                                                                    [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
                                                                });
                                                                
                                                                if (error) {
                                                                    FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
                                                                    [alert show];
                                                                    
                                                                    return;
                                                                }
                                                                
                                                                if (responseObject) {
                                                                    if ([self.usernameTextField isEqual:[NSNull null]] || ![self.usernameTextField.text isEqualToString:@""]) {
                                                                        [[FRSUserManager sharedInstance] authenticatedUser].username = [self.usernameTextField.text substringFromIndex:1];
                                                                    }
                                                                    
                                                                    if ([self.emailTextField isEqual:[NSNull null]] || ![self.emailTextField.text isEqualToString:@""]) {
                                                                        [[FRSUserManager sharedInstance] authenticatedUser].email = self.emailTextField.text;
                                                                    }
                                                                }
                                                            }
                                                            
                                                            [self dismiss];
                                                        }];
}
- (void)checkEmail {
    //Prepopulated from login
    if (!self.emailTextField.userInteractionEnabled) {
        return;
    }
    
    [[FRSUserManager sharedInstance] checkEmail:self.emailTextField.text
                                     completion:^(id responseObject, NSError *error) {
                                         
                                         if (!error) {
                                             self.emailTaken = YES;
                                             [self shouldShowEmailError:YES];
                                         } else {
                                             self.emailTaken = NO;
                                             [self shouldShowEmailError:NO];
                                         }
                                         
                                         [self checkCreateAccountButtonState];
                                     }];
}

- (void)shouldShowEmailError:(BOOL)error {
    if (error) {
        self.emailCheckIV.alpha = 1;
    } else {
        self.emailCheckIV.alpha = 0;
    }
}

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

- (void)usernameTimerFired {
    if ([self.usernameTextField.text isEqualToString:@""]) {
        self.usernameCheckIV.alpha = 0;
        self.usernameTakenLabel.alpha = 0;
        [self stopUsernameTimer];
        return;
    }
    
    // Check for emoji and error
    if ([[self.usernameTextField.text substringFromIndex:1] stringContainsEmoji]) {
        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
        return;
    }
    
    if (self.usernameTextField.isEditing && (![[self.usernameTextField.text substringFromIndex:1] stringContainsEmoji])) {
        if ((![[self.usernameTextField.text substringFromIndex:1] isEqualToString:@""])) {
            [[FRSUserManager sharedInstance] checkUsername:[self.usernameTextField.text substringFromIndex:1]
                                                completion:^(id responseObject, NSError *error) {
                                                    //Return if no internet
                                                    if (error.code == -1009) {
                                                        FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
                                                        [alert show];
                                                        return;
                                                    }
                                                    NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                    NSInteger responseCode = response.statusCode;
                                                    
                                                    if (responseCode == 404) { //
                                                        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:YES];
                                                        self.usernameTaken = NO;
                                                        [self stopUsernameTimer];
                                                        [self checkCreateAccountButtonState];
                                                        return;
                                                    } else {
                                                        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
                                                        self.usernameTaken = YES;
                                                        [self stopUsernameTimer];
                                                        [self checkCreateAccountButtonState];
                                                    }
                                                }];
        }
    }
}

- (void)animateUsernameCheckImageView:(UIImageView *)imageView animateIn:(BOOL)animateIn success:(BOOL)success {
    if (success) {
        self.usernameCheckIV.image = [UIImage imageNamed:@""];
        self.usernameTakenLabel.alpha = 0;
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
        self.usernameTakenLabel.alpha = 1;
    }
    
    if (animateIn) {
        if (self.usernameCheckIV.alpha == 0) {
            
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.usernameCheckIV.alpha = 0;
            self.usernameCheckIV.alpha = 1;
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1, 1);
        }
    } else {
        
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
        self.usernameCheckIV.alpha = 0;
    }
}

- (void)checkCreateAccountButtonState {
    UIControlState controlState;
    
    //Only updating username
    if (!self.passwordTextField && !self.emailTextField && self.usernameTextField) {
        if ([[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
    
    //Only updaing email
    if (!self.passwordTextField && self.emailTextField && !self.usernameTextField) {
        if ([self.emailTextField.text isValidEmail] && (!self.emailTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
    
    //Only updating password
    if (self.passwordTextField && !self.emailTextField && !self.usernameTextField) {
        if ([self.passwordTextField.text length] >= 6) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
    
    //Updating password and username
    if (self.passwordTextField && !self.emailTextField && self.usernameTextField) {
        if ([self.passwordTextField.text length] >= 6 && [[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
    
    //Updating password and email
    if (self.passwordTextField && self.emailTextField && !self.usernameTextField) {
        if ([self.passwordTextField.text length] >= 6 && [self.emailTextField.text isValidEmail] && (!self.emailTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
    
    //Updating username and email
    if (!self.passwordTextField && self.emailTextField && self.usernameTextField) {
        if ([[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken) && [self.emailTextField.text isValidEmail] && (!self.emailTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
    
    //Updaing username, email, and password
    if (self.passwordTextField && self.emailTextField && self.usernameTextField) {
        if ([[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken) && [self.emailTextField.text isValidEmail] && (!self.emailTaken) && [self.passwordTextField.text length] >= 6) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
}

- (void)toggleCreateAccountButtonTitleColorToState:(UIControlState)controlState {
    if (controlState == UIControlStateNormal) {
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
    } else {
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[[UIColor frescoBlueColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        self.cancelButton.enabled = YES;
    }
}

- (void)tap {
    [self resignFirstResponder];
    [self endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (self.migrationAlertShouldShowPassword) {
                             self.transform = CGAffineTransformMakeTranslation(0, -100);
                         } else {
                             self.transform = CGAffineTransformMakeTranslation(0, -80);
                         }
                         
                     }
                     completion:nil];
    
    if (self.emailTextField.isEditing) {
        self.emailCheckIV.alpha = 0;
    }
    
    if (textField.tag == 1) {
        [self startUsernameTimer];
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"@";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        if ([textField.text isEqualToString:@"@"]) {
            textField.text = @"";
        }
    }
    
    if ((textField == self.emailTextField) && ([self.emailTextField.text isValidEmail])) {
        [self checkEmail];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                     }
                     completion:nil];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ((textField == self.emailTextField) && ([self.emailTextField.text isValidEmail])) {
        [self checkEmail];
    }
    
    if (textField == self.usernameTextField) {
        if ([textField.text isEqualToString:@"@"]) {
            [self checkCreateAccountButtonState];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.usernameTextField.isEditing) {
        [self startUsernameTimer];
        
        if ([[self.usernameTextField.text substringFromIndex:1] isEqualToString:@""]) {
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:NO success:NO];
        }
    }
    
    [self checkCreateAccountButtonState];
    
    if (textField.tag == 1) {
        
        if ([string containsString:@" "]) {
            return NO;
        }
        
        if (textField.text.length == 1 && [string isEqualToString:@""]) {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 20;
    }
    
    return YES;
}

@end
