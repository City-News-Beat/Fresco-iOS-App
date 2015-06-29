//
//  FirstRunSignUpViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "FirstRunSignUpViewController.h"
#import "FRSDataManager.h"

@import FBSDKLoginKit;
@import FBSDKCoreKit;

@interface FirstRunSignUpViewController ()
@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textfieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldLastName;
@end

@implementation FirstRunSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.];
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
    
    [self setFacebookInfo];
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

- (IBAction)actionNext:(id)sender {
    // save this to allow backing to the VC
    self.firstName = [self.textfieldFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.lastName = [self.textfieldLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // both fields must be populated
    if (([self.firstName length] && [self.lastName length])) {
        NSDictionary *updateParams = @{ @"firstname" : self.firstName, @"lastname" : self.lastName };
        
        [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams block:^(id responseObject, NSError *error) {
            if (!error) {
                [self performSegueWithIdentifier:@"showPermissions" sender:self];
            }
            else
                NSLog(@"Error: %@", error);
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter both first and last name"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Social data
- (void)setFacebookInfo
{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
       // self.firstName
//        self.facebookLabel.hidden = YES;
//        self.facebookIcon.hidden = YES;
        return;
    }
    
    NSDictionary *params = @{@"fields": @"name,picture"};
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:params
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
           // self.facebookLabel.text = [result objectForKey:@"name"];
        }
        else {
//            self.facebookLabel.hidden = YES;
//            self.facebookIcon.hidden = YES;
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textfieldFirstName isFirstResponder] && [touch view] != self.textfieldFirstName) {
        [self.textfieldFirstName resignFirstResponder];
    }
    
    if ([self.textfieldLastName isFirstResponder] && [touch view] != self.textfieldLastName) {
        [self.textfieldLastName resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showPermissions"]) {
    }
}
@end
