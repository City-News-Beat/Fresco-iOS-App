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

    //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
    UITapGestureRecognizer *settingsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    
    [self.settingsButtonView addGestureRecognizer:settingsTap];

}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:YES];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:UD_UPDATE_PROFILE_HEADER]){
        
        [self updateUserInfo];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UD_UPDATE_PROFILE_HEADER];
    
    }
    
}

/*
** Updates the profile header info with the latest data
*/

-(void)updateUserInfo{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"avatar"] != nil){
        
        [self.profileImageView
         setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatar"]]
         placeholderImage:[UIImage imageNamed:@"user"]];
    
    }
    else{
        
        [self.profileImageView setImage:[UIImage imageNamed:@"user"]];
        
    }

    NSString *first = [[NSUserDefaults standardUserDefaults] stringForKey:UD_FIRSTNAME];
    
    NSString *last = [[NSUserDefaults standardUserDefaults] stringForKey:UD_LASTNAME];
    
    if(first == nil && last == nil){
        
        //Set the display name
        self.labelDisplayName.text = @"Unnamed User";
    
    }
    else{
        
        //Set the display name
        self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@",  first , last];
    
    }

    
    //Update the corner radius on the user image
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    
    [self setTwitterInfo];
    [self setFacebookInfo];
    
}

/*
** Sends us to the settings screen
*/

-(void)handleSingleTap {
    
    //Make sure we're connected first
    if([[FRSDataManager sharedManager] connected]){
    
        [self performSegueWithIdentifier:SEG_SETTINGS sender:self];
        
    }
}

- (void)setTwitterInfo
{
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.twitterLabel.hidden = YES;
        self.twitterIcon.hidden = YES;
    }
    else{
    
        self.twitterLabel.text = [NSString stringWithFormat:@"@%@", [PFTwitterUtils twitter].screenName];
    
    }
}

- (void)setFacebookInfo
{
    
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.facebookLabel.hidden = YES;
        self.facebookIcon.hidden = YES;
    }
    else{

        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil HTTPMethod:@"GET"];
        
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            if (!error) {
                self.facebookLabel.hidden = NO;
                self.facebookIcon.hidden = NO;
                self.facebookLabel.text = [result objectForKey:@"name"];
            }
            else {
                self.facebookLabel.hidden = YES;
                self.facebookIcon.hidden = YES;
            }
        }];
    }

}

@end
