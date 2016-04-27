//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLoginViewController.h"
#import "FRSOnboardingViewController.h"
#import "FRSAPIClient.h"

@interface FRSLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *usernameHighlightLine;
@property (weak, nonatomic) IBOutlet UIView *passwordHighlightLine;

@property(nonatomic, copy) NSArray *viewControllers;

@property (weak, nonatomic) IBOutlet UIButton *backArrowButton;

@property (nonatomic) BOOL didAnimate;

@end

@implementation FRSLoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.didAnimate = NO;
    
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
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(12, 30, 24, 24);
    [self.backButton setImage:[UIImage imageNamed:@"back-arrow-dark"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.tintColor = [UIColor frescoMediumTextColor];
    [self.view addSubview:self.backButton];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor frescoLightTextColor]}];
    
    self.userField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email or @username" attributes:@{NSForegroundColorAttributeName: [UIColor frescoLightTextColor]}];
}

-(instancetype)init {
    self = [super initWithNibName:@"FRSLoginViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        
    }
    
    return self;
}
- (IBAction)returnToPreviousViewController:(id)sender {
    
 [self.navigationController popViewControllerAnimated:YES];

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
}

-(IBAction)login:(id)sender {

}

-(IBAction)twitter:(id)sender {

    [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error) {
    }];
    
}

-(IBAction)facebook:(id)sender {
    
    [FRSSocial loginWithFacebook:^(BOOL authenticated, NSError *error) {
        //
    } parent:self];
}

-(IBAction)next:(id)sender {
    [self.passwordField becomeFirstResponder];
}

-(void)back {

    [self animateOut];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        //TODO
        //Make delegate
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"returnToOnboard"
         object:self];
    });
}


#pragma mark - UITextFieldDelegate

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
    
    if (self.userField.editing) {

        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.usernameHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:nil];
        
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.passwordHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 0.5);
            
        } completion:nil];
    }
    
    
    if (self.passwordField.editing) {

        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.passwordHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:nil];
        
        [UIView animateWithDuration:.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 0.5);
            
        } completion:nil];
    }
}


-(void)textFieldDidChange:(UITextField *)textField {
    
    if (self.userField.text && self.userField.text.length > 0) {
        if (self.passwordField.text && self.passwordField.text.length >= 8) {
            
            if ([self validEmail:self.userField.text] || [self isValidUsername:self.userField.text]) {
                
                self.loginButton.enabled = YES;
                
                /* Fade title color */
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
                
                /* Fade title color */
                [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.loginButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
                } completion:nil];
        }
    }
    
    if ([self.userField.text isEqualToString:@""]) {
        [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.loginButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        } completion:nil];
    }
}


- (BOOL) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}


-(BOOL)isValidUsername:(NSString *)username {
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validUsernameChars];
    NSCharacterSet *disallowedSet = [allowedSet invertedSet];
    NSRange rangeOfFound = [username rangeOfCharacterFromSet:disallowedSet];
    
    return ([username rangeOfCharacterFromSet:disallowedSet].location == NSNotFound);
}




#pragma mark - Transition Animations

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
    
}

-(void)animateIn {
    
    self.didAnimate = YES;
    
    [self prepareForAnimation];
    
    /* Transform and fade backButton xPos */
    [UIView animateWithDuration:0.6 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backButton.transform = CGAffineTransformMakeTranslation(0, 0);
        self.backButton.alpha = 1;
    } completion:nil];
    
    /* Transform userField */
    [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.userField.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.userField.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.userField.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade usernameHighlightLine */
    [UIView animateWithDuration:0.5 delay:0.05 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.usernameHighlightLine.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade passwordField */
    [UIView animateWithDuration:0.5 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordField.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.passwordField.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade passwordHighlightLine */
    [UIView animateWithDuration:0.5 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.passwordHighlightLine.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    /* Transform and fade loginButton */
    [UIView animateWithDuration:0.5 delay:0.25 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(-5, 0);
        self.loginButton.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.loginButton.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }];
    
    
    [UIView animateWithDuration:0.7 delay:0.3 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.3 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:1.0 delay:0.35 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.35 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:1.0 delay:0.4 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.4 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.alpha = 1;
    } completion:^(BOOL finished) {
        self.backButton.enabled = YES;
    }];
}

-(void)animateOut {
    
    /* Transform backButton xPos */
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backButton.transform = CGAffineTransformMakeTranslation(5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backButton.transform = CGAffineTransformMakeTranslation(-20, 0);
            self.backButton.alpha = 0;
        } completion:nil];
    }];

    /* Transform userField */
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.userField.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.userField.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];

    [UIView animateWithDuration:0.4 delay:0.4 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.userField.alpha = 0;
    } completion:nil];
    
    /* Transform usernameHighlightLine */
    [UIView animateWithDuration:0.3 delay:0.05 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4 delay:0.45 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.usernameHighlightLine.alpha = 0;
    } completion:nil];
    
    /* Transform passwordField */
    [UIView animateWithDuration:0.3 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordField.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordField.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4 delay:0.5 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.passwordField.alpha = 0;
    } completion:nil];
    
    /* Transform passwordHighlightLine */
    [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.passwordHighlightLine.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4 delay:0.55 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.passwordHighlightLine.alpha = 0;
    } completion:nil];
    
    /* Transform loginButton */
    [UIView animateWithDuration:0.3 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(-5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.loginButton.transform = CGAffineTransformMakeTranslation(100, 0);
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.4 delay:0.6 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.loginButton.alpha = 0;
    } completion:nil];
    
    [UIView animateWithDuration:1.0 delay:0.5 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.transform = CGAffineTransformMakeTranslation(100, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.5 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.facebookButton.alpha = 0;
    } completion:nil];
    
    [UIView animateWithDuration:1.0 delay:0.55 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.transform = CGAffineTransformMakeTranslation(80, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.55 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twitterButton.alpha = 0;
    } completion:nil];
    
    [UIView animateWithDuration:0.7 delay:0.6 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.transform = CGAffineTransformMakeTranslation(60, 0);
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.6 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.socialLabel.alpha = 0;
    } completion:nil];
}





@end
