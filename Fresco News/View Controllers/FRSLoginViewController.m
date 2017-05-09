//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLoginViewController.h"
#import "FRSOnboardingViewController.h"
#import "FRSTabBarController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSAlertView.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import <UXCam/UXCam.h>
#import "NSString+Validation.h"
#import "FRSConnectivityAlertView.h"

@interface FRSLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *usernameHighlightLine;
@property (weak, nonatomic) IBOutlet UIView *passwordHighlightLine;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet UIButton *passwordHelpButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialTopConstraint;

@property (nonatomic) BOOL didAnimate;
@property (nonatomic) BOOL didTransform;
@property (nonatomic) BOOL isLoggingIn;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) UILabel *invalidUserLabel;
@property (nonatomic) BOOL didAuthenticateSocial;
@property (strong, nonatomic) FBSDKLoginManager *fbLoginManager;

@end

@implementation FRSLoginViewController

#pragma mark - View Controller Life Cycle

- (instancetype)init {
    self = [super initWithNibName:@"FRSLoginViewController" bundle:[NSBundle mainBundle]];

    if (self) {
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureSpinner];

    self.didAnimate = NO;
    self.didTransform = NO;

    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor] }];

    self.userField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email or @username" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor] }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    if (IS_IPHONE_5) {
        self.socialTopConstraint.constant = 104;
    } else if (IS_IPHONE_6) {
        self.socialTopConstraint.constant = 120.8;
    } else if (IS_IPHONE_6_PLUS) {
        self.socialTopConstraint.constant = 128;
    }

    self.fbLoginManager = [[FBSDKLoginManager alloc] init];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    [self hideSensitiveViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    if (!self.didAnimate) {
        [self animateIn];
    }

    self.twitterButton.tintColor = [UIColor twitterBlueColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FRSTracker track:onboardingReads];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    if (!self.didAnimate) {
        self.backButton.alpha = 0;
        self.userField.alpha = 0;
        self.usernameHighlightLine.alpha = 0;
        self.passwordField.alpha = 0;
        self.passwordHelpButton.alpha = 0;
        self.passwordHighlightLine.alpha = 0;
        self.loginButton.alpha = 0;
        self.socialLabel.alpha = 0;
        self.twitterButton.alpha = 0;
        self.facebookButton.alpha = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Spinner

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

- (void)pushViewControllerWithCompletion:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self.navigationController pushViewController:viewController animated:animated];
    [CATransaction commit];
}

- (void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 - 16, button.frame.size.height / 2 - 10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

- (void)stopSpinner:(DGElasticPullToRefreshLoadingView *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [spinner stopLoading];
    [spinner removeFromSuperview];
}

#pragma mark - Actions

- (void)logoutAlertAction {
    [self logoutWithPop:NO];
}

- (void)presentInvalidInfo {
    [UIView animateWithDuration:0.15
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.passwordHighlightLine.backgroundColor = [UIColor frescoRedColor];
          self.usernameHighlightLine.backgroundColor = [UIColor frescoRedColor];
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.15
                                delay:1.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             self.passwordHighlightLine.backgroundColor = [UIColor frescoLightTextColor];
                             self.usernameHighlightLine.backgroundColor = [UIColor frescoLightTextColor];
                           }
                           completion:nil];
        }];
}

- (void)dismiss {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];

    CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
    [translate setFromValue:[NSNumber numberWithFloat:self.view.center.y]];
    [translate setToValue:[NSNumber numberWithFloat:self.view.center.y + 50]];
    [translate setDuration:0.6];
    [translate setRemovedOnCompletion:NO];
    [translate setFillMode:kCAFillModeForwards];
    [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4:0:0:1.0]];
    [[self.view layer] addAnimation:translate forKey:@"translate"];

    [self animateAlphaView:self.view withDuration:0.3 withDelay:0 andAlpha:0];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self popToOrigin];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)popToOrigin {
    [[FRSUserManager sharedInstance] reloadUser];

    NSArray *viewControllers = [self.navigationController viewControllers];

    if ([viewControllers count] == 3) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if ([viewControllers count] >= 3) {
        [self.navigationController popToViewController:[viewControllers objectAtIndex:2] animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (IBAction)login:(id)sender {
    [self dismissKeyboard];

    if (self.isLoggingIn) {
        return;
    }

    //Animate transition
    NSString *username = _userField.text;
    if (username.length > 1 && [[username substringToIndex:1] isEqualToString:@"@"]) {
        username = [username substringFromIndex:1];
    }
    NSString *password = _passwordField.text;
    if ([password isEqualToString:@""] || [username isEqualToString:@""]) {
        // error out
        [self presentInvalidInfo];
        return;
    }

    [self startSpinner:self.loadingView onButton:self.loginButton];

    //checks if username is a username, if not it's an email.
    if (![username isValidUsername]) {
        username = _userField.text;
    }

    self.isLoggingIn = YES;
    [[FRSAuthManager sharedInstance] signIn:username
                                   password:password
                                 completion:^(id responseObject, NSError *error) {
                                   self.isLoggingIn = NO;
                                   if (error) {
                                       [FRSTracker track:loginError
                                              parameters:@{ @"method" : @"email",
                                                            @"error" : error.localizedDescription }];
                                   }

                                   [self stopSpinner:self.loadingView onButton:self.loginButton];

                                   if (error.code == 0) {
                                       
                                       [self popToOrigin];

                                       if (self.passwordField.text != nil && ![self.passwordField.text isEqualToString:@""]) {
                                           [[FRSAuthManager sharedInstance] setPasswordUsed:self.passwordField.text];
                                       }

                                       [[FRSAuthManager sharedInstance] setPasswordUsed:self.passwordField.text];

                                       if ([username isValidEmail]) {
                                           [[FRSAuthManager sharedInstance] setEmailUsed:self.userField.text];
                                       }


                                       [self checkStatusAndPresentPermissionsAlert:YES];
                                       
                                       return;
                                   }

                                   if (error.code == -1009) {
                                       FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
                                       [alert show];
                                       return;
                                   }

                                   NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                   NSInteger responseCode = response.statusCode;
                                   if (responseCode == 401) {
                                       [self presentInvalidInfo];
                                       return;
                                   }
                                   if (error) {
                                       [self presentGenericError];
                                   }
                                 }];
}

- (IBAction)twitter:(id)sender {
    if (self.isLoggingIn) {
        return;
    }

    self.twitterButton.hidden = true;
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [self.twitterButton.superview addSubview:spinner];
    [spinner setFrame:CGRectMake(self.twitterButton.frame.origin.x, self.twitterButton.frame.origin.y, self.twitterButton.frame.size.width, self.twitterButton.frame.size.width)];

    [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token, id responseObject) {
      if (error) {
          [FRSTracker track:loginError
                 parameters:@{ @"method" : @"twitter",
                               @"error" : error.localizedDescription }];
      }
      if (authenticated) {
          NSDictionary *socialLinksDict = responseObject[@"user"][@"social_links"];

          if (socialLinksDict[@"facebook"] != nil) {
              [[NSUserDefaults standardUserDefaults] setBool:YES forKey:facebookConnected];
          }

          self.didAuthenticateSocial = YES;

          [self checkStatusAndPresentPermissionsAlert:YES];
          [self popToOrigin];

          return;
      }

      if (error) {
          if (error.code == -1009) {
              FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
              [alert show];
              [spinner stopLoading];
              [spinner removeFromSuperview];
              self.twitterButton.hidden = false;
              return;
          }

          FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"COULDN’T LOG IN" message:@"We couldn’t verify your Twitter account. Please try logging in with your email and password." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
          [alert show];
      }

      [spinner stopLoading];
      [spinner removeFromSuperview];
      self.twitterButton.hidden = false;
    }];
}

- (IBAction)facebook:(id)sender {
    if (self.isLoggingIn) {
        return;
    }

    self.facebookButton.hidden = true;
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [self.facebookButton.superview addSubview:spinner];
    [spinner setFrame:CGRectMake(self.facebookButton.frame.origin.x, self.facebookButton.frame.origin.y, self.facebookButton.frame.size.width, self.facebookButton.frame.size.width)];

    [FRSSocial loginWithFacebook:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token, NSDictionary *responseObject) {
      if (error) {
          [FRSTracker track:loginError
                 parameters:@{ @"method" : @"facebook",
                               @"error" : error.localizedDescription }];

          if (error.code == -1009) {
              FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
              [alert show];
              [spinner stopLoading];
              [spinner removeFromSuperview];
              self.facebookButton.hidden = false;
              return;
          } else if (error.code == 301) {
              //User dismisses view controller (done/cancel top left)
          }

          FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"COULDN’T LOG IN" message:@"We couldn’t verify your Facebook account. Please try logging in with your email and password." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
          [alert show];
      }

      if (authenticated) {
          NSDictionary *socialDigest = [[FRSAuthManager sharedInstance] socialDigestionWithTwitter:nil facebook:[FBSDKAccessToken currentAccessToken]];
          
          [[FRSUserManager sharedInstance] updateUserWithDigestion:socialDigest
                                                        completion:^(id responseObject, NSError *error) {
                                                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:facebookConnected];
                                                            
                                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"name" }] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                                if (!error) {
                                                                    [[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"name"] forKey:facebookName];
                                                                }
                                                            }];
                                                        }];
          self.didAuthenticateSocial = YES;
          [self checkStatusAndPresentPermissionsAlert:YES];
          [self popToOrigin];
          
          [spinner stopLoading];
          [spinner removeFromSuperview];
          self.facebookButton.hidden = false;
          return;
        }
        
        [spinner stopLoading];
        [spinner removeFromSuperview];
        self.facebookButton.hidden = false;
    }
                          parent:self
                         manager:self.fbLoginManager];
}

- (IBAction)next:(id)sender {
    [self.passwordField becomeFirstResponder];
}

- (IBAction)back:(id)sender {
    [self dismissKeyboard];
    [self animateOut];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 / 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.navigationController popViewControllerAnimated:NO];

      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"returnToOnboard"
                        object:self];
    });
}

- (IBAction)passwordHelp:(id)sender {
    [self highlightTextField:nil enabled:NO];

    [self.passwordField resignFirstResponder];
    [self.userField resignFirstResponder];

    [self animateFramesForKeyboard:YES];
    //patience, my friend. patience.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      NSURL *url = [NSURL URLWithString:@"https://www.fresconews.com/forgot"];
      [[UIApplication sharedApplication] openURL:url];
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userField) {
        if ((![self.userField.text isValidUsername] && ![self.userField.text isValidEmail]) || [self.userField.text isEqualToString:@""]) {
            [self animateTextFieldError:textField];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.userField.editing) {
        if (range.length + range.location > textField.text.length) {
            return NO;
        }

        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 40;
    }
    return YES;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField {
    [self highlightTextField:textField enabled:YES];
    [self animateAlphaView:self.passwordHelpButton withDuration:0.15 withDelay:0 andAlpha:1];

    if (!self.didTransform) {
        [self animateFramesForKeyboard:NO];
    }
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField {
    [self animateAlphaView:self.passwordHelpButton withDuration:0.15 withDelay:0 andAlpha:0];

    if (!self.didTransform) {
        [self animateFramesForKeyboard:YES];
    }
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    if ((self.userField.text && self.userField.text.length > 0) && (self.passwordField.text && self.passwordField.text.length >= 1)) {
        if ([self.userField.text isValidEmail] || [self.userField.text isValidUsername]) {
            self.loginButton.enabled = YES;
            [self animateTextColor:self.loginButton withDuration:0.2 andColor:[UIColor frescoBlueColor]];
        } else {
            [self animateTextColor:self.loginButton withDuration:0.2 andColor:[UIColor frescoLightTextColor]];
        }
    } else if (self.passwordField.text && self.passwordField.text.length < 4) { //SHOULD BE 8, BROUGHT DOWN TO 4 TO TEST MAURICES PASSWORD
        self.loginButton.enabled = NO;
        [self animateTextColor:self.loginButton withDuration:0.2 andColor:[UIColor frescoLightTextColor]];
    }

    if ([self.userField.text isEqualToString:@""]) {
        [self animateTextColor:self.loginButton withDuration:0.2 andColor:[UIColor frescoLightTextColor]];
    }

    if (self.passwordField.editing && ![self.passwordField.text isEqualToString:@""]) { //check whitespace?
        [self animateAlphaView:self.passwordHelpButton withDuration:0.15 withDelay:0 andAlpha:1];
    } else {
        [self animateAlphaView:self.passwordHelpButton withDuration:0.15 withDelay:0 andAlpha:0];
    }
}

- (void)highlightTextField:(UITextField *)textField enabled:(BOOL)enabled {
    if (!enabled) {
        [UIView animateWithDuration:.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
                           self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
                           self.passwordHighlightLine.backgroundColor = [UIColor frescoShadowColor];
                           self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:nil];

        [self animateAlphaView:self.passwordHelpButton withDuration:0.15 withDelay:0 andAlpha:0];
        return;
    }

    if (textField.editing == self.userField.editing) {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.usernameHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
                           self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1.5);
                         }
                         completion:nil];

        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.passwordHighlightLine.backgroundColor = [UIColor frescoShadowColor];
                           self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:nil];

    } else if (textField.editing == self.passwordField.editing) {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.passwordHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
                           self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1.5);
                         }
                         completion:nil];

        [UIView animateWithDuration:.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
                           self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:nil];
    }
}

- (void)dismissKeyboard {

    if (self.userField.isEditing || self.passwordField.isEditing) {
        [self highlightTextField:nil enabled:NO];

        [self.userField resignFirstResponder];
        [self.passwordField resignFirstResponder];

        [self animateFramesForKeyboard:YES];
    }
}

- (void)animateFramesForKeyboard:(BOOL)hidden {
    if (hidden) {
        [UIView animateWithDuration:0.4
            delay:0.0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{

              if (IS_IPHONE_5) {
                  self.view.transform = CGAffineTransformMakeTranslation(0, 0);
              } else if (IS_IPHONE_6) {
                  self.socialLabel.transform = CGAffineTransformMakeTranslation(0, 0);
                  self.facebookButton.transform = CGAffineTransformMakeTranslation(0, 0);
                  self.twitterButton.transform = CGAffineTransformMakeTranslation(0, 0);
              }
            }
            completion:^(BOOL finished) {
              self.didTransform = NO;
            }];
    } else {
        [UIView animateWithDuration:0.25
            delay:0.0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
              if (IS_IPHONE_5) {
                  self.view.transform = CGAffineTransformMakeTranslation(0, -116);
              } else if (IS_IPHONE_6) {
                  self.socialLabel.transform = CGAffineTransformMakeTranslation(0, -20);
                  self.facebookButton.transform = CGAffineTransformMakeTranslation(0, -20);
                  self.twitterButton.transform = CGAffineTransformMakeTranslation(0, -20);
              }
            }
            completion:^(BOOL finished) {
              self.didTransform = YES;
            }];
    }
}

#pragma mark - Animation

- (void)animateAlphaView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay andAlpha:(CGFloat)alpha {
    [self animateAlphaView:view withDuration:duration withDelay:delay andAlpha:alpha completion:nil];
}

- (void)animateAlphaView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay andAlpha:(CGFloat)alpha completion:(void (^__nullable)(BOOL finished))completion {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       view.alpha = alpha;
                     }
                     completion:completion];
}

- (void)animateTextColor:(UIButton *)button withDuration:(NSTimeInterval)duration andColor:(UIColor *)color {
    [UIView transitionWithView:button
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                      [button setTitleColor:color forState:UIControlStateNormal];
                    }
                    completion:nil];
}

- (void)animateTransformView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay andTransform:(CGAffineTransform)transform {
    [self animateTransformView:view withDuration:duration withDelay:delay andTransform:transform completion:nil];
}

- (void)animateTransformView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay andTransform:(CGAffineTransform)transform completion:(void (^__nullable)(BOOL finished))completion {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       view.transform = transform;
                     }
                     completion:completion];
}

- (void)animateTextFieldError:(UITextField *)textField {
    CGFloat duration = 0.1;

    /* SHAKE */

    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          textField.transform = CGAffineTransformMakeTranslation(-7.5, 0);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:duration
              delay:0.0
              options:UIViewAnimationOptionCurveEaseInOut
              animations:^{
                textField.transform = CGAffineTransformMakeTranslation(5, 0);
              }
              completion:^(BOOL finished) {
                [UIView animateWithDuration:duration
                    delay:0.0
                    options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                      textField.transform = CGAffineTransformMakeTranslation(-2.5, 0);
                    }
                    completion:^(BOOL finished) {
                      [UIView animateWithDuration:duration
                          delay:0.0
                          options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                            textField.transform = CGAffineTransformMakeTranslation(2.5, 0);
                          }
                          completion:^(BOOL finished) {
                            [UIView animateWithDuration:duration
                                                  delay:0.0
                                                options:UIViewAnimationOptionCurveEaseInOut
                                             animations:^{
                                               textField.transform = CGAffineTransformMakeTranslation(0, 0);
                                             }
                                             completion:nil];
                          }];
                    }];
              }];
        }];
}

- (void)prepareForAnimation {
    self.backButton.alpha = 0;
    self.backButton.transform = CGAffineTransformMakeTranslation(20, 0);
    self.backButton.enabled = NO;

    self.userField.alpha = 0;
    self.userField.transform = CGAffineTransformMakeTranslation(50, 0);

    self.usernameHighlightLine.alpha = 0;
    self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(50, 0);

    self.passwordField.alpha = 0;
    self.passwordField.transform = CGAffineTransformMakeTranslation(50, 0);

    self.passwordHighlightLine.alpha = 0;
    self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(50, 0);

    self.loginButton.alpha = 0;
    self.loginButton.transform = CGAffineTransformMakeTranslation(50, 0);

    self.socialLabel.transform = CGAffineTransformMakeTranslation(30, 0);
    self.socialLabel.alpha = 0;

    self.facebookButton.transform = CGAffineTransformMakeTranslation(20, 0);
    self.facebookButton.alpha = 0;

    self.twitterButton.transform = CGAffineTransformMakeTranslation(20, 0);
    self.twitterButton.alpha = 0;

    self.passwordHelpButton.alpha = 0;
}

- (void)animateIn {
    self.didAnimate = YES;

    [self prepareForAnimation];

    /* Transform and fade backButton xPos */
    [UIView animateWithDuration:0.6 / 2
                          delay:0.2 / 2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.backButton.transform = CGAffineTransformMakeTranslation(0, 0);
                       self.backButton.alpha = 1;
                     }
                     completion:nil];

    /* Transform userField */
    [UIView animateWithDuration:0.5 / 2
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.userField.transform = CGAffineTransformMakeTranslation(-5, 0);
          self.userField.alpha = 1;
        }
        completion:^(BOOL finished) {
          [self animateTransformView:self.userField withDuration:0.15 withDelay:0 andTransform:CGAffineTransformMakeTranslation(0, 0)];
        }];

    /* Transform and fade usernameHighlightLine */
    [UIView animateWithDuration:0.5 / 2
        delay:0.05 / 2
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
          self.usernameHighlightLine.alpha = 1;
        }
        completion:^(BOOL finished) {
          [self animateTransformView:self.usernameHighlightLine withDuration:0.15 withDelay:0 andTransform:CGAffineTransformMakeTranslation(0, 0)];
        }];

    /* Transform and fade passwordField */
    [UIView animateWithDuration:0.5 / 2
        delay:0.1 / 2
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.passwordField.transform = CGAffineTransformMakeTranslation(-5, 0);
          self.passwordField.alpha = 1;
        }
        completion:^(BOOL finished) {
          [self animateTransformView:self.passwordField withDuration:0.15 withDelay:0 andTransform:CGAffineTransformMakeTranslation(0, 0)];
        }];

    /* Transform and fade passwordHighlightLine */
    [UIView animateWithDuration:0.5 / 2
        delay:0.2 / 2
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
          self.passwordHighlightLine.alpha = 1;
        }
        completion:^(BOOL finished) {
          [self animateTransformView:self.passwordHighlightLine withDuration:0.15 withDelay:0 andTransform:CGAffineTransformMakeTranslation(0, 0)];
        }];

    /* Transform and fade loginButton */
    [UIView animateWithDuration:0.5 / 2
        delay:0.25 / 2
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.loginButton.transform = CGAffineTransformMakeTranslation(-5, 0);
          self.loginButton.alpha = 1;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.3 / 2
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             self.loginButton.transform = CGAffineTransformMakeTranslation(0, 0);
                           }
                           completion:nil];
        }];

    /* Transform and fade social line */
    [self animateTransformView:self.socialLabel withDuration:0.35 withDelay:0.15 andTransform:CGAffineTransformMakeTranslation(0, 0)];
    [self animateAlphaView:self.socialLabel withDuration:0.25 withDelay:0.15 andAlpha:1];

    [self animateTransformView:self.twitterButton withDuration:0.5 withDelay:0.175 andTransform:CGAffineTransformMakeTranslation(0, 0)];
    [self animateAlphaView:self.twitterButton withDuration:0.15 withDelay:0.175 andAlpha:1];

    [self animateTransformView:self.facebookButton withDuration:0.5 withDelay:0.2 andTransform:CGAffineTransformMakeTranslation(0, 0)];
    [self animateAlphaView:self.facebookButton
              withDuration:0.15
                 withDelay:0.2
                  andAlpha:1
                completion:^(BOOL finished) {
                  self.backButton.enabled = YES;
                }];
}

- (void)animateOut {
    /* Transform backButton xPos */
    [self animateTransformView:self.backButton
                  withDuration:0.1
                     withDelay:0
                  andTransform:CGAffineTransformMakeTranslation(5, 0)
                    completion:^(BOOL finished) {
                      [UIView animateWithDuration:0.5 / 2
                                            delay:0.0
                                          options:UIViewAnimationOptionCurveEaseInOut
                                       animations:^{
                                         self.backButton.transform = CGAffineTransformMakeTranslation(-20, 0);
                                         self.backButton.alpha = 0;
                                       }
                                       completion:nil];
                    }];

    /* Transform userField */
    [self animateTransformView:self.userField
                  withDuration:0.16
                     withDelay:0
                  andTransform:CGAffineTransformMakeTranslation(-5, 0)
                    completion:^(BOOL finished) {
                      [self animateTransformView:self.userField withDuration:0.35 withDelay:0 andTransform:CGAffineTransformMakeTranslation(100, 0)];
                    }];

    [self animateAlphaView:self.userField withDuration:0.2 withDelay:0 andAlpha:0];

    [self animateAlphaView:self.userField withDuration:0.2 withDelay:0.2 andAlpha:0];

    /* Transform usernameHighlightLine */
    [self animateTransformView:self.usernameHighlightLine
                  withDuration:0.15
                     withDelay:0.025
                  andTransform:CGAffineTransformMakeTranslation(-5, 0)
                    completion:^(BOOL finished) {
                      [self animateTransformView:self.usernameHighlightLine withDuration:0.35 withDelay:0 andTransform:CGAffineTransformMakeTranslation(100, 0)];
                    }];

    [self animateAlphaView:self.usernameHighlightLine withDuration:0.2 withDelay:0.225 andAlpha:0];

    /* Transform passwordField and helpButton */
    [UIView animateWithDuration:0.3 / 2
        delay:0.1 / 2
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.passwordField.transform = CGAffineTransformMakeTranslation(-5, 0);
          self.passwordHelpButton.transform = CGAffineTransformMakeTranslation(-5, 0);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.7 / 2
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             self.passwordField.transform = CGAffineTransformMakeTranslation(100, 0);
                             self.passwordHelpButton.transform = CGAffineTransformMakeTranslation(100, 0);

                           }
                           completion:nil];
        }];

    [UIView animateWithDuration:0.4 / 2
                          delay:0.5 / 2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       self.passwordField.alpha = 0;
                       self.passwordHelpButton.alpha = 0;
                     }
                     completion:nil];

    /* Transform passwordHighlightLine */
    [self animateTransformView:self.passwordHighlightLine
                  withDuration:0.15
                     withDelay:0.025
                  andTransform:CGAffineTransformMakeTranslation(-5, 0)
                    completion:^(BOOL finished) {
                      [self animateTransformView:self.passwordHighlightLine withDuration:0.35 withDelay:0 andTransform:CGAffineTransformMakeTranslation(100, 0)];
                    }];

    [self animateAlphaView:self.passwordHighlightLine withDuration:0.2 withDelay:0.225 andAlpha:0];

    /* Transform loginButton */
    [self animateTransformView:self.loginButton
                  withDuration:0.15
                     withDelay:0.01
                  andTransform:CGAffineTransformMakeTranslation(-5, 0)
                    completion:^(BOOL finished) {
                      [self animateTransformView:self.loginButton withDuration:0.35 withDelay:0 andTransform:CGAffineTransformMakeTranslation(100, 0)];
                    }];

    [self animateAlphaView:self.loginButton withDuration:0.2 withDelay:0.3 andAlpha:0];

    /* Transform and fade social line */
    [self animateTransformView:self.facebookButton withDuration:0.5 withDelay:0.25 andTransform:CGAffineTransformMakeTranslation(100, 0)];
    [self animateAlphaView:self.facebookButton withDuration:0.15 withDelay:0.25 andAlpha:0];

    [self animateTransformView:self.twitterButton withDuration:0.5 withDelay:0.275 andTransform:CGAffineTransformMakeTranslation(80, 0)];
    [self animateAlphaView:self.twitterButton withDuration:0.15 withDelay:0.275 andAlpha:0];

    [self animateTransformView:self.socialLabel withDuration:0.35 withDelay:0.3 andTransform:CGAffineTransformMakeTranslation(60, 0)];
    [self animateAlphaView:self.socialLabel withDuration:0.25 withDelay:0.3 andAlpha:0];
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.passwordField];
}

@end

