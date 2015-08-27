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


#pragma mark - Login / Signup Methods

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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PROFILE_PIC_RESET object:self];
    
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

/*
 ** Login Method, takes a LoginType to perform repsective login i.e. facebook, twitter, regular login (fresco)
 */

- (void)performLogin:(LoginType)login button:(UIButton *)button withLoginInfo:(NSDictionary *)info{
    
    self.view.userInteractionEnabled = NO;
    
    [button setTitle:@"" forState:UIControlStateNormal];
    
    CGRect spinnerFrame = CGRectMake(0,0, 20, 20);
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
    
    self.spinner.center = CGPointMake(button.frame.size.width  / 2, button.frame.size.height / 2);
    
    self.spinner.color = [UIColor whiteColor];
    
    [self.spinner startAnimating];
    
    [button addSubview:self.spinner];
    
    [UIView animateWithDuration:.3 animations:^{
        
        for (UIView *view in [self.view subviews]) {
            if(view != button && view.tag!= 51 && view.tag != 50){
                view.alpha = .26f;
            }
            
        }
        
    }];
    
    if(login == LoginFresco){
        
        [[FRSDataManager sharedManager] loginUser:info[@"email"] password:info[@"password"] block:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else{
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:INVALID_CREDENTIALS action:nil]
                                   animated:YES completion:^{
                                       [button setTitle:LOGIN forState:UIControlStateNormal];
                                       
                                       [self revertScreenToNormal];
                                       
                                   }];
            }
            
        }];
        
    }
    else if(login == LoginFacebook){
        
        //Facebook icon image
        [self.view viewWithTag:51].hidden = YES;
        
        [[FRSDataManager sharedManager] loginViaFacebookWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else {
                //TODO: check if these are the strings we want
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:FACEBOOK_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:^{
                                     
                                     [button setTitle:FACEBOOK forState:UIControlStateNormal];
                                     
                                     [self revertScreenToNormal];
                                 }];
                
            }
            
        }];
        
    }
    else if(login == LoginTwitter){
        
        //Twitter icon image
        [self.view viewWithTag:50].hidden = YES;
        
        [[FRSDataManager sharedManager] loginViaTwitterWithBlock:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else {
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:TWITTER_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:^{
                                     
                                     [button setTitle:TWITTER forState:UIControlStateNormal];
                                     [self revertScreenToNormal];
                                     
                                 }];
                
                NSLog(@"%@", error);
                
            }
        }];
        
    }
}

- (void)revertScreenToNormal{
    
    self.view.userInteractionEnabled = YES;
    
    //Social Images
    [self.view viewWithTag:50].hidden = NO;
    [self.view viewWithTag:51].hidden = NO;
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.spinner.alpha = 0;
        
        for (UIView *view in [self.view subviews]) view.alpha = 1;
        
    }];
    
}



@end
