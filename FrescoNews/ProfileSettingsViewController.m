//
//  ProfileSettingsViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 5/12/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ProfileSettingsViewController.h"

@interface ProfileSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *connectFacebookButton;
@property (weak, nonatomic) PFUser *currentUser;
@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentUser = [PFUser currentUser];
    
    // NSLog(@"%@",self.currentUser); // Undo to print user in log
    
    [self updateLinkingStatus];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLinkingStatus {
    
    if (!self.currentUser) {
        [self.connectTwitterButton setHidden:YES];
        [self.connectFacebookButton setHidden:YES];
    } else {
        [self.connectTwitterButton setHidden:NO];
        [self.connectFacebookButton setHidden:NO];
    
        if ([PFTwitterUtils isLinkedWithUser:self.currentUser]) {
            [self.connectTwitterButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        } else {
            [self.connectTwitterButton setTitle:@"Connect" forState:UIControlStateNormal];
        }
    
        if ([PFFacebookUtils isLinkedWithUser:self.currentUser]) {
            [self.connectFacebookButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        } else {
            [self.connectFacebookButton setTitle:@"Connect" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)connectFacebook:(id)sender {
    [self.connectFacebookButton setTitle:@"" forState:UIControlStateNormal];
    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(20, 20, (self.connectFacebookButton.frame.size.width - 40), 7)];
    spinner.color = [UIColor whiteColor];
    [spinner startAnimating];
    [self.connectFacebookButton addSubview:spinner];
        
    if (![PFFacebookUtils isLinkedWithUser:self.currentUser]) {
        [PFFacebookUtils linkUserInBackground:self.currentUser withReadPermissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Woohoo, user is linked with Facebook!");
            } else {
                NSLog(@"%@", error);
            }
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
        }];
    } else {
        [PFFacebookUtils unlinkUserInBackground:self.currentUser block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"The user is no longer associated with their Facebook account.");
                
            } else {
                NSLog(@"%@", error);
            }
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
        }];
    }

}

- (IBAction)connectTwitter:(id)sender {
    [self.connectTwitterButton setTitle:@"" forState:UIControlStateNormal];
    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(20, 20, (self.connectTwitterButton.frame.size.width - 40), 7)];
    spinner.color = [UIColor whiteColor];
    [spinner startAnimating];
    [self.connectTwitterButton addSubview:spinner];

    if (![PFTwitterUtils isLinkedWithUser:self.currentUser]) {
        [PFTwitterUtils linkUser:self.currentUser block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:self.currentUser]) {
                NSLog(@"Woohoo, user logged in with Twitter!");
            } else {
                NSLog(@"%@", error);
            }
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
        }];
    } else {
        [PFTwitterUtils unlinkUserInBackground:self.currentUser block:^(BOOL succeeded, NSError *error) {
            if (!error && succeeded) {
                NSLog(@"The user is no longer associated with their Twitter account.");
            } else {
                NSLog(@"%@", error);
            }
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
        }];
    }

}

- (IBAction)logOut:(id)sender {
    [PFUser logOut];
    [self updateLinkingStatus];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
