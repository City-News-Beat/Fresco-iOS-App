//
//  FirstRunViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunViewController.h"
#import "FRSDataManager.h"
#import "AppDelegate.h"

@interface FirstRunViewController ()

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;


@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end

@implementation FirstRunViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self styleButtons];
    
    // this allows us to NEXT to fields
    self.emailField.delegate = self;
    self.passwordField.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)styleButtons {
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    
    self.signUpButton.layer.cornerRadius = 8;
    self.signUpButton.clipsToBounds = YES;
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            CGFloat height = 0;
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                height = -1 * [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                            }
                            
                            self.topVerticalSpaceConstraint.constant = height;
                            self.bottomVerticalSpaceConstraint.constant = -1 * height;
                            [self.view layoutIfNeeded];
                        } completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonAction:(id)sender {
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self.emailField.text options:0 range:NSMakeRange(0, [self.emailField.text length])];
    
    if ([self.emailField.text length]!=0 && regExMatches!=0) { // Run Log In Method
        [PFUser logInWithUsernameInBackground:[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] password:self.passwordField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            
                                            //TODO: set the current user and pfuser in datamanager
                                            // very first time the user needs to get a Fresco Id
                                            NSLog(@"user : %@", user);
                                            NSLog(@"cache: %@", [PFUser currentUser]);
                                            
                                            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) setRootViewControllerToTabBar];
                                        } else {
                                            NSLog(@"Login failed : %@", error);
                                        }
                                    }];
    } else { // Show error state
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh boy" message:@"You've screwed up and mistyped your email" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles:nil, nil];
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
        
        self.emailField.textColor = [UIColor redColor];
    }
}

- (IBAction) signUpButtonAction:(id)sender {
    PFUser *user = [PFUser user];
    user.password = self.passwordField.text;
    user.username = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:user.email options:0 range:NSMakeRange(0, [user.email length])];
    
    if ([user.email length]!=0 && regExMatches!=0) { // Run Sign Up Method
    
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Hooray! Let them use the app now.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh boy" message:@"You're signed up now" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles:nil, nil];
                [alert addButtonWithTitle:@"GOO"];
                [alert show];
                
                //[self.navigationController pushViewController: animated:YES]
            }
        }];
        
    } else { // Show error state
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh boy" message:@"You've screwed up and mistyped your email" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles:nil, nil];
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
        
        self.emailField.textColor = [UIColor redColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //[self.loginButtonAction:sender];
        [self.loginButton resignFirstResponder];
    }
    return YES;
}

- (IBAction)facebookLogin:(id)sender {
    [PFFacebookUtils logInInBackgroundWithPublishPermissions:@[ @"publish_actions" ] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else {
            [[FRSDataManager sharedManager] currentUserFromParseUser];
            [self navigateToMainApp];
            NSLog(@"User now has publish permissions!");
        }
    }];
}

- (IBAction)twitterLogin:(id)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
        } else {
            NSLog(@"User logged in with Twitter!");
        }
    }];
}

@end
