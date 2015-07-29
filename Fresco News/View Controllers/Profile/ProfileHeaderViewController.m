//
//  ProfileHeaderViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/9/15.
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
@property (weak, nonatomic) IBOutlet UIView *settingsButtonView;

@end

@implementation ProfileHeaderViewController

- (void)viewDidLoad{

    [super viewDidLoad];
    
    [self updateUserInfo];

}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:YES];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"updateProfileHeader"]){
        
        [self updateUserInfo];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"updateProfileHeader"];
    
    }
    
}

/*
** Updates the profile header info with the latest data
*/

-(void)updateUserInfo{
    
    if([FRSDataManager sharedManager].currentUser != nil){

        self.labelDisplayName.text = [FRSDataManager sharedManager].currentUser.displayName;
        
        //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
        UITapGestureRecognizer *settingsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        
        [self.settingsButtonView addGestureRecognizer:settingsTap];
        
        [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[[FRSDataManager sharedManager].currentUser avatarUrl]]
                                     placeholderImage:[UIImage imageNamed:@"user"]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  self.profileImageView.image = image;
                                                  self.profileImageView.clipsToBounds = YES;
                                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  // Do something...
                                              }];
    
        
        
    }
    else{
    
        self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@",  [[NSUserDefaults standardUserDefaults] stringForKey:@"firstname"]  ,  [[NSUserDefaults standardUserDefaults] stringForKey:@"lastname"]];
        
    
    }
    
    [self setTwitterInfo];
    [self setFacebookInfo];
    
    //Update the corner radius on the user image
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;

}

/*
** Sends us to the settings screen
*/

-(void)handleSingleTap {
    
    //Make sure we're connected first
    if([[FRSDataManager sharedManager] connected]){
    
        [self performSegueWithIdentifier:@"settingsSegue" sender:self];
        
    }
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
    if(data){
    
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if(!results[@"errors"])
        
            self.twitterLabel.text = [NSString stringWithFormat:@"@%@", [results objectForKey:@"screen_name"]];
        
    }
}

- (void)setFacebookInfo
{
    
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.facebookLabel.hidden = YES;
        self.facebookIcon.hidden = YES;
        return;
    }

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil HTTPMethod:@"GET"];
    
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
