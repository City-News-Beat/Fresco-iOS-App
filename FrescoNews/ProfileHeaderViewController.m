//
//  ProfileHeaderViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Parse;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "ProfileHeaderViewController.h"
#import "FRSUser.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FRSDataManager.h"

@interface ProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIcon;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end

@implementation ProfileHeaderViewController

- (void)viewWillAppear:(BOOL)animated
{
    // this will have to change for displaying other users
    self.frsUser = [FRSDataManager sharedManager].currentUser;
    
    [super viewWillAppear:animated];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.frsUser.first, self.frsUser.last];

    if (self.frsUser.profileImageUrl) {
        [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.frsUser cdnProfileImageURL]]
                                     placeholderImage:[UIImage imageNamed:@"user"]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  self.profileImageView.image = image;
                                                  self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
                                                  self.profileImageView.clipsToBounds = YES;
                                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  // Do something...
                                              }];
    }
    else {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = YES;
    }

    [self setTwitterInfo];
    [self setFacebookInfo];
}

- (void)setTwitterInfo
{
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.twitterLabel.hidden = YES;
        self.twitterIcon.hidden = YES;
        return;
    }

    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:twitterRequest];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:twitterRequest
                                         returningResponse:&response
                                                     error:nil];
    
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    self.twitterLabel.text = [NSString stringWithFormat:@"@%@", [results objectForKey:@"screen_name"]];
}

- (void)setFacebookInfo
{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.facebookLabel.hidden = YES;
        self.facebookIcon.hidden = YES;
        return;
    }

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:nil
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        NSLog(@"%@", error);
        if (!error) {
            self.facebookLabel.text = [result objectForKey:@"name"];
        }
        else {
            self.facebookLabel.hidden = YES;
            self.facebookIcon.hidden = YES;
        }
    }];
}

@end
