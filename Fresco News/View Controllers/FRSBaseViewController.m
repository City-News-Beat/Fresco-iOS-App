//
//  FRSBaseViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/7/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSRootViewController.h"
#import "UIViewController+Additions.h"
#import "FRSBaseViewController.h"
#import "FRSGallery.h"
#import "GalleryHeader.h"
#import "FRSDataManager.h"
#import "AppDelegate.h"

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
}

// good for wholesale resetting of the app
- (void)navigateToMainApp
{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc setRootViewControllerToTabBar];
}


- (void)navigateToCamera{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc setRootViewControllerToCamera];
}

- (void)navigateToFirstRun
{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc presentFirstRunViewController:self];
}


/*
** Method to send us out of view controller
*/

- (void)transferUser{
    
    //Set has Launched Before to prevent onboard from ocurring again
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_HAS_LAUNCHED_BEFORE];
    
    //Tells profile to update
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_UPDATE_PROFILE];
    
    //Tells rest of the app to update respective occurence of the user's profile picture
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePicReset" object:self];
    
    //New user, send them to rest of the first run
    if ([PFUser currentUser].isNew || ![[FRSDataManager sharedManager] currentUserValid]){
        
        //Sets condition for agreegement to the TOS
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UD_TOS_AGREED];
        
        [self performSegueWithIdentifier:SEG_REPLACE_WITH_SIGNUP sender:self];
        
    }
    //User hasn't agreed to TOS
    else if(![[NSUserDefaults standardUserDefaults] boolForKey:UD_TOS_AGREED]){
        [self performSegueWithIdentifier:SEG_REPLACE_WITH_TOS sender:self];
    }
    //User has agreed and already exists i.e. send them back to the app
    else{
        if(self.presentingViewController == nil)
            [self navigateToMainApp];
        else{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
