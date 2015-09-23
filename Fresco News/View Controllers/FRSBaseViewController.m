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
#import "UISocialButton.h"
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_IMAGE_SET object:nil];
    
    //New user, send them to rest of the first run
    if ([PFUser currentUser].isNew || ![[FRSDataManager sharedManager] currentUserValid]){
        
        [self performSegueWithIdentifier:SEG_REPLACE_WITH_SIGNUP sender:self];
        
    }
    //User is valid and exists i.e. send them back to the app
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

    dispatch_async(dispatch_get_main_queue(), ^{

        self.view.userInteractionEnabled = NO;
        
        [button setTitle:@"" forState:UIControlStateNormal];
        
        if(button.imageView.image)
            [button setImage:nil forState:UIControlStateNormal];
        
        CGRect spinnerFrame = CGRectMake(0,0, 20, 20);
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
        
        self.spinner.center = CGPointMake(button.frame.size.width  / 2, button.frame.size.height / 2);
        
        self.spinner.color = [UIColor whiteColor];
        
        [self.spinner startAnimating];
        
        [button addSubview:self.spinner];
        
        [self hideViewsExceptView:button withView:self.view];
            
    });

    if(login == LoginFresco){

        [[FRSDataManager sharedManager] loginUser:info[@"email"] password:info[@"password"] block:^(PFUser *user, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            
            if ([[FRSDataManager sharedManager] currentUserIsLoaded]) {
                
                [self transferUser];
                
            }
            else{
                
                [button setTitle:LOGIN forState:UIControlStateNormal];
                [self hideActivityIndicator];
                [self revertScreenToNormal:self.view];
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:INVALID_CREDENTIALS action:nil]
                                   animated:YES completion:nil];
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
                
                
                [button setTitle:FACEBOOK forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:FACEBOOK] forState:UIControlStateNormal];
                [self hideActivityIndicator];
                [self revertScreenToNormal:self.view];
                
                //TODO: check if these are the strings we want
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:FACEBOOK_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:nil];
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
                
                [button setTitle:TWITTER forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
                [self revertScreenToNormal:self.view];
                [self hideActivityIndicator];
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:LOGIN_ERROR
                                             message:TWITTER_ERROR
                                             action:DISMISS]
                                   animated:YES
                                 completion:nil];
            }
        }];
    }
}

- (void)hideActivityIndicator{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.spinner removeFromSuperview];
            
    });
    
}

- (void)revertScreenToNormal:(UIView *)parentView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.view.userInteractionEnabled = YES;

        // Get the subviews of the view
        NSArray *subviews = [parentView subviews];
        
        // Return if there are no subviews
        if ([subviews count] == 0)
            return; // COUNT CHECK LINE
        
        [UIView animateWithDuration:.3 animations:^{
            
            for (UIView *subview in subviews) {
                
                subview.alpha = 1.0f;
                
                // List the subviews of subview fater
                [self revertScreenToNormal:subview];
                
            }
            
        }];
        
    });
    
}

- (void)hideViewsExceptView:(UIView *)exceptionView withView:(UIView *)parentView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        // Get the subviews of the view
        NSArray *subviews = [parentView subviews];
        
        // Return if there are no subviews
        if ([subviews count] == 0) return; // COUNT CHECK LINE
        
        [UIView animateWithDuration:.3 animations:^{
            
            for (UIView *subview in subviews) {
                
                if(subview != exceptionView && subview != exceptionView.superview)
                    subview.alpha = .26f;

                if(subview != exceptionView){
                    // List the subviews of subview after
                    [self hideViewsExceptView:exceptionView withView:subview];
                }
                
            }
            
        }];
        
    });
    
}



@end
