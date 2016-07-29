//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

//View Controllers
#import "FRSLoginViewController.h"
#import "FRSOnboardingViewController.h"
#import "FRSTabBarController.h"
#import "FRSUploadViewController.h"

//API
#import "FRSAPIClient.h"

//Cocoapods
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSAppDelegate.h"

//Alert View
#import "FRSAlertView.h"

@interface FRSLoginViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL didAnimate;
@property (nonatomic) BOOL didTransform;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialTopConstraint;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) UILabel *invalidUserLabel;
@property (nonatomic) BOOL didAuthenticateSocial;

@end

@implementation FRSLoginViewController


#pragma mark - View Controller Life Cycle

-(instancetype)init {
    self = [super initWithNibName:@"FRSLoginViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        
    }
    
    return self;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureSpinner];
    
    self.didAnimate = NO;
    self.didTransform = NO;
    
    self.twitterButton.tintColor = [UIColor colorWithRed:0 green:0.675 blue:0.929 alpha:1]; /*Twitter Blue*/
    self.facebookButton.tintColor = [UIColor colorWithRed:0.231 green:0.349 blue:0.596 alpha:1]; /*Facebook Blue*/
    
    self.passwordField.tintColor = [UIColor frescoShadowColor];
    self.userField.tintColor = [UIColor frescoShadowColor];
    
    self.userField.delegate = self;
    self.passwordField.delegate = self;
    
    UIView *emailLine = [[UIView alloc] initWithFrame:CGRectMake(self.userField.frame.origin.x, self.userField.frame.origin.y, self.userField.frame.size.width, 1)];
    emailLine.backgroundColor = [UIColor frescoOrangeColor];
    [self.userField addSubview:emailLine];
    
    self.userField.tintColor = [UIColor frescoOrangeColor];
    self.passwordField.tintColor = [UIColor frescoOrangeColor];
    
    [self.userField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.loginButton.enabled = NO;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(12, 30, 24, 24);
    [self.backButton setImage:[UIImage imageNamed:@"back-arrow-dark"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //    self.backButton.tintColor = [UIColor frescoMediumTextColor];
    [self.view addSubview:self.backButton];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor frescoLightTextColor]}];
    
    self.userField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email or @username" attributes:@{NSForegroundColorAttributeName: [UIColor frescoLightTextColor]}];
    
    self.userField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    /*
     OMAR THIS IS WHAT CONSTRAINTS ARE FOR, SO U DONT NEED RANDOM NUMBERS
     */
    
    if (IS_IPHONE_5) {
        self.socialTopConstraint.constant = 104;
    } else if (IS_IPHONE_6) {
        self.socialTopConstraint.constant = 120.8;
    } else if (IS_IPHONE_6_PLUS) {
        self.socialTopConstraint.constant = 128;
    }
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (!self.didAnimate) {
        [self animateIn];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Spinner

-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

-(void)pushViewControllerWithCompletion:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self.navigationController pushViewController:viewController animated:animated];
    [CATransaction commit];
}

-(void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 -16, button.frame.size.height/2 -10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

-(void)stopSpinner:(DGElasticPullToRefreshLoadingView *)spinner onButton:(UIButton *)button {
    
    [button setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [spinner stopLoading];
    [spinner removeFromSuperview];
}

#pragma mark - Actions

-(IBAction)login:(id)sender {
    
    [self dismissKeyboard];
    
    //Animate transition
    NSString *username = _userField.text;
    NSString *password = _passwordField.text;
    
    if ([password isEqualToString:@""] || [username isEqualToString:@""] || (![self isValidUsername:username] && ![self validEmail:username])) {
        // error out
        
        return;
    }
    
    
    [self startSpinner:self.loadingView onButton:self.loginButton];
    
    
    [[FRSAPIClient sharedClient] signIn:username password:password completion:^(id responseObject, NSError *error) {
        
        [self stopSpinner:self.loadingView onButton:self.loginButton];
        
        if (error.code == 0) {
            FRSTabBarController *tabBarVC = [[FRSTabBarController alloc] init];
            [self pushViewControllerWithCompletion:tabBarVC animated:NO completion:^{
                [self stopSpinner:self.loadingView onButton:self.loginButton];
            }];
        }
        
        if (error.code == -1009) {
            NSLog(@"Unable to connect.");
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to connect to the internet. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:self];
            [alert show];
            return;
        }
        
        NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
        NSInteger responseCode = response.statusCode;
        NSLog(@"ERROR: %ld", (long)responseCode);
        
        if (responseCode >= 400 && responseCode < 500) {
            // 400 level, client
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
            [alert show];
            return;
        }
        else if (responseCode >= 500 && responseCode < 600) {
            // 500 level, server
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
            [alert show];
            return;
        }
        else if (responseCode >= 300 && responseCode < 400) {
            // 300  level, unauthorized
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
            [alert show];
            return;
        }
        
        if (error.code == -1011) {
            NSLog(@"Invalid username or password.");
            [self presentInvalidInfo];
        }
    }];
}

-(void)presentInvalidInfo {
    
    //should turn fields red instead of this
    
    self.loginButton.userInteractionEnabled = NO;
    self.invalidUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.passwordField.frame.origin.x, self.passwordField.frame.origin.y + self.passwordField.frame.size.height + 16, 200, 18)];
    self.invalidUserLabel.textAlignment = NSTextAlignmentLeft;
    self.invalidUserLabel.text = @"Invalid username or password.";
    self.invalidUserLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    self.invalidUserLabel.textColor = [UIColor frescoRedHeartColor];
    self.invalidUserLabel.alpha = 0;
    [self.view addSubview:self.invalidUserLabel];
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.invalidUserLabel.alpha = 1;
        self.invalidUserLabel.transform = CGAffineTransformMakeTranslation(0, 8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.7 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.invalidUserLabel.alpha = 0;
            self.invalidUserLabel.transform = CGAffineTransformMakeTranslation(0, 16);
        } completion:^(BOOL finished) {
            [self.invalidUserLabel removeFromSuperview];
            self.loginButton.userInteractionEnabled = YES;
        }];
    }];
}

-(void)dismiss {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
    [translate setFromValue:[NSNumber numberWithFloat:self.view.center.y]];
    [translate setToValue:[NSNumber numberWithFloat:self.view.center.y +50]];
    [translate setDuration:0.6];
    [translate setRemovedOnCompletion:NO];
    [translate setFillMode:kCAFillModeForwards];
    [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
    [[self.view layer] addAnimation:translate forKey:@"translate"];
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(IBAction)twitter:(id)sender {
    self.twitterButton.hidden = true;
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [self.twitterButton.superview addSubview:spinner];
    [spinner  setFrame:CGRectMake(self.twitterButton.frame.origin.x, self.twitterButton.frame.origin.y, self.twitterButton.frame.size.width, self.twitterButton.frame.size.width)];
    //NSLog(@"%f x %f", self.twitterButton.frame.size.width,self.twitterButton.frame.size.width-2);
    
    [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
        
        if (authenticated) {
            self.didAuthenticateSocial = YES;
            [self popToOrigin];
        }
        
        
        if (error) {
            NSLog(@"TWITTER SIGN IN: %@", error);

            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"COULDN’T LOG IN" message:@"We couldn’t verify your Twitter account. Please try logging in with your email and password." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:self];
            [alert show];
        }

        [spinner stopLoading];
        [spinner removeFromSuperview];
        self.twitterButton.hidden = false;
    }];
}

-(void)popToOrigin {
    
    //FRSUploadViewController *uploadVC = [[FRSUploadViewController alloc] init];
    //[self pushViewControllerWithCompletion:uploadVC animated:NO completion:nil];
    
    //    FRSTabBarController *tabBarVC = [[FRSTabBarController alloc] init];
    //    [self pushViewControllerWithCompletion:tabBarVC animated:NO completion:nil];
    
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate reloadUser];
    
    NSArray *viewControllers = [self.navigationController viewControllers];    
    
    if ([viewControllers count] == 3) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:[viewControllers objectAtIndex:2] animated:YES];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(IBAction)facebook:(id)sender {
    self.facebookButton.hidden = true;
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [self.facebookButton.superview addSubview:spinner];
    [spinner  setFrame:CGRectMake(self.facebookButton.frame.origin.x, self.facebookButton.frame.origin.y, self.facebookButton.frame.size.width, self.facebookButton.frame.size.width)];
    
    [FRSSocial loginWithFacebook:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
        if (authenticated) {
            
            self.didAuthenticateSocial = YES;
            NSLog(@"Popped");
            [self popToOrigin];
        }else{
            NSLog(@"Else");
        }
        
        if (error) {
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"COULDN’T LOG IN" message:@"We couldn’t verify your Twitter account. Please try logging in with your email and password." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:self];
            [alert show];
        }
        
        [spinner stopLoading];
        [spinner removeFromSuperview];
        self.facebookButton.hidden = false;
    } parent:self];
}


-(IBAction)next:(id)sender {
    [self.passwordField becomeFirstResponder];
}


-(void)back {
    [self dismissKeyboard];
    [self animateOut];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9/2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:NO];
        //        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"returnToOnboard"
         object:self];
    });
}

-(IBAction)passwordHelp:(id)sender {
    
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userField) {
        if ((![self isValidUsername:self.userField.text] && ![self validEmail:self.userField.text]) || [self.userField.text isEqualToString:@""]) {
            [self animateTextFieldError:textField];
            return FALSE;
        }
    }
    
    return TRUE;
}

-(void)animateTextFieldError:(UITextField *)textField {
    
    CGFloat duration = 0.1;
    
    /* SHAKE */
    
    [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        textField.transform = CGAffineTransformMakeTranslation(-7.5, 0);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            textField.transform = CGAffineTransformMakeTranslation(5, 0);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                
                textField.transform = CGAffineTransformMakeTranslation(-2.5, 0);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    textField.transform = CGAffineTransformMakeTranslation(2.5, 0);
                    
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                        
                        textField.transform = CGAffineTransformMakeTranslation(0, 0);
                        
                    } completion:nil];
                }];
            }];
        }];
    }];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.userField.editing) {
        if(range.length + range.location > textField.text.length) {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 40;
    }
    
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self highlightTextField:textField enabled:YES];
    
    if (self.passwordField.editing) {
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHelpButton.alpha = 1;
        } completion:nil];
    }
    
    if (!self.didTransform) {
        
        [self animateFramesForKeyboard:NO];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordHelpButton.alpha = 0;
    } completion:nil];
    
    
    if (!self.didTransform) {
        
        [self animateFramesForKeyboard:YES];
    }
}


-(void)textFieldDidChange:(UITextField *)textField {
    
    if ((self.userField.text && self.userField.text.length > 0) && (self.passwordField.text && self.passwordField.text.length >= 8)) {
        
        if ([self validEmail:self.userField.text] || [self isValidUsername:self.userField.text]) {
            
            self.loginButton.enabled = YES;
            
            [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.loginButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
            } completion:nil];
            
        } else {
            
            [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.loginButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
            } completion:nil];
        }
        
    } else if (self.passwordField.text && self.passwordField.text.length < 8) {
        
        self.loginButton.enabled = NO;
        
        [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.loginButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        } completion:nil];
    }
    
    if ([self.userField.text isEqualToString:@""]) {
        [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.loginButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        } completion:nil];
    }
    
    if (self.passwordField.editing && ![self.passwordField.text isEqualToString:@""]) { //check whitespace?
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHelpButton.alpha = 1;
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHelpButton.alpha = 0;
        } completion:nil];
    }
}


-(void)highlightTextField:(UITextField *)textField enabled:(BOOL)enabled {
    
    if (!enabled) {
        [UIView animateWithDuration:.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
            self.passwordHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
        
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHelpButton.alpha = 0;
        } completion:nil];
        return;
    }
    
    if (textField.editing == self.userField.editing) {
        
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1.5);
        } completion:nil];
        
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
        
    } else if (textField.editing == self.passwordField.editing) {
        
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1.5);
        } completion:nil];
        
        [UIView animateWithDuration:.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    }
}


-(void)dismissKeyboard {
    
    if (self.userField.isEditing || self.passwordField.isEditing) {
        [self highlightTextField:nil enabled:NO];
        
        [self.userField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        
        [self animateFramesForKeyboard:YES];
    }
}


-(void)animateFramesForKeyboard:(BOOL)hidden {
    
    if (hidden) {
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            if (IS_IPHONE_5) {
                self.view.transform = CGAffineTransformMakeTranslation(0, 0);
            } else if (IS_IPHONE_6) {
                self.socialLabel.transform = CGAffineTransformMakeTranslation(0, 0);
                self.facebookButton.transform = CGAffineTransformMakeTranslation(0, 0);
                self.twitterButton.transform = CGAffineTransformMakeTranslation(0, 0);
            }
        } completion:^(BOOL finished) {
            self.didTransform = NO;
        }];
    } else {
        [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            if (IS_IPHONE_5) {
                self.view.transform = CGAffineTransformMakeTranslation(0, -116);
            } else if (IS_IPHONE_6) {
                self.socialLabel.transform = CGAffineTransformMakeTranslation(0, -20);
                self.facebookButton.transform = CGAffineTransformMakeTranslation(0, -20);
                self.twitterButton.transform = CGAffineTransformMakeTranslation(0, -20);
            }
        } completion:^(BOOL finished) {
            self.didTransform = YES;
        }];
    }
}



#pragma mark - Textfield Validation

-(BOOL)validEmail:(NSString *)emailString {
    
    if([emailString length] == 0) {
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)isValidUsername:(NSString *)username {
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validUsernameChars];
    NSCharacterSet *disallowedSet = [allowedSet invertedSet];
    return ([username rangeOfCharacterFromSet:disallowedSet].location == NSNotFound);
}




#pragma mark - Animation

-(void)prepareForAnimation {
    
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

-(void)animateIn {
    
    self.didAnimate = YES;
    
    [self prepareForAnimation];
    
    /* Transform and fade backButton xPos */
    [UIView animateWithDuration:0.6/2 delay:0.2/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backButton.transform = CGAffineTransformMakeTranslation(0, 0);
        self.backButton.alpha = 1;
    } completion:nil];
    
    /* Transform userField */
    [UIView animateWithDuration:0.5/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.userField.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.userField.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.userField.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade usernameHighlightLine */
    [UIView animateWithDuration:0.5/2 delay:0.05/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.usernameHighlightLine.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade passwordField */
    [UIView animateWithDuration:0.5/2 delay:0.1/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordField.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.passwordField.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade passwordHighlightLine */
    [UIView animateWithDuration:0.5/2 delay:0.2/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.passwordHighlightLine.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade loginButton */
    [UIView animateWithDuration:0.5/2 delay:0.25/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.loginButton.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.loginButton.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade social line */
    
    [UIView animateWithDuration:0.7/2 delay:0.3/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.5/2 delay:0.3/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:1.0/2 delay:0.35/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3/2 delay:0.35/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:1.0/2 delay:0.4/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3/2 delay:0.4/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.alpha = 1;
    } completion:^(BOOL finished) {
        self.backButton.enabled = YES;
    }];
}

-(void)animateOut {
    
    /* Transform backButton xPos */
    [UIView animateWithDuration:0.2/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backButton.transform = CGAffineTransformMakeTranslation(5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backButton.transform = CGAffineTransformMakeTranslation(-20, 0);
            self.backButton.alpha = 0;
        } completion:nil];
    }];
    
    /* Transform userField */
    [UIView animateWithDuration:0.3/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.userField.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.userField.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4/2 delay:0.4/2 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.userField.alpha = 0;
    } completion:nil];
    
    /* Transform usernameHighlightLine */
    [UIView animateWithDuration:0.3/2 delay:0.05/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4/2 delay:0.45/2 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.usernameHighlightLine.alpha = 0;
    } completion:nil];
    
    /* Transform passwordField and helpButton */
    [UIView animateWithDuration:0.3/2 delay:0.1/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordField.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.passwordHelpButton.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordField.transform = CGAffineTransformMakeTranslation(100, 0);
            self.passwordHelpButton.transform = CGAffineTransformMakeTranslation(100, 0);
            
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4/2 delay:0.5/2 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.passwordField.alpha = 0;
        self.passwordHelpButton.alpha = 0;
    } completion:nil];
    
    /* Transform passwordHighlightLine */
    [UIView animateWithDuration:0.3/2 delay:0.15/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4/2 delay:0.55/2 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.passwordHighlightLine.alpha = 0;
    } completion:nil];
    
    /* Transform loginButton */
    [UIView animateWithDuration:0.3/2 delay:0.2/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7/2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.loginButton.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4/2 delay:0.6/2 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.loginButton.alpha = 0;
    } completion:nil];
    
    /* Transform and fade social line */
    [UIView animateWithDuration:1.0/2 delay:0.5/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.transform = CGAffineTransformMakeTranslation(100, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3/2 delay:0.5/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.alpha = 0;
    } completion:nil];
    
    [UIView animateWithDuration:1.0/2 delay:0.55/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.transform = CGAffineTransformMakeTranslation(80, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3/2 delay:0.55/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.alpha = 0;
    } completion:nil];
    
    [UIView animateWithDuration:0.7/2 delay:0.6/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.transform = CGAffineTransformMakeTranslation(60, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.5/2 delay:0.6/2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.alpha = 0;
    } completion:nil];
    
}









@end

