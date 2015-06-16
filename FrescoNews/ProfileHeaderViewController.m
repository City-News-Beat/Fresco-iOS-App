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


@interface ProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelDisplayName;

@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIcon;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation ProfileHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.frsUser.first, self.frsUser.last];
    
    [self.profileImageView setImageWithURL:[self.frsUser cdnProfileImageURL]];
    
    
    [self setTwitterInfo];
    [self setFacebookInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTwitterInfo {
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:twitterRequest];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:twitterRequest
                                         returningResponse:&response
                                                     error:nil];
    
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    
    self.twitterLabel.text = [NSString stringWithFormat:@"%@", [results objectForKey:@"screen_name"]];

}

- (void)setFacebookInfo {
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/{user_id}"
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        NSLog(@"%@", error);
        if (!error) {
            NSString *facebookId = [result objectForKey:@"id"];
            self.facebookLabel.text = facebookId;
        } else {
            self.facebookLabel.hidden = YES;
            self.facebookIcon.hidden = YES;
        }
    }];

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
