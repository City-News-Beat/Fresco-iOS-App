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
#import "FirstRunPageViewController.h"
#import "FRSSocialButton.h"
#import "FRSFirstRunWrapperViewController.h"

@implementation FRSBaseViewController

- (instancetype)initWithIndex:(NSInteger)index{
    
    self = [super init];
    
    if(self) self.index = index;

    return self;
    
}


- (void)navigateToMainApp
{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc setRootViewControllerToTabBar];
}


- (void)navigateToCamera{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc setRootViewControllerToCamera];
}

- (void)presentFirstRun
{
    FRSFirstRunWrapperViewController *vc = [[FRSFirstRunWrapperViewController alloc] init];

    [self presentViewController:vc animated:YES completion:nil];
}

- (void)navigateToNextIndex{

    //Move to next page
    if([self.parentViewController isKindOfClass:[FirstRunPageViewController class]]){
        [((FirstRunPageViewController *)self.parentViewController) moveToViewAtIndex:self.index + 1 withDirection:UIPageViewControllerNavigationDirectionForward];
    }
    
}

#pragma mark - Login / Signup Methods

- (void)transferUser{
    
    //Set has launched before to prevent onboard from ocurring again
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_HAS_LAUNCHED_BEFORE];
    
    //Tells profile to update
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_UPDATE_PROFILE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Tells rest of the app to update respective occurence of the user's profile picture
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_IMAGE_SET object:nil];
    
    //New user, send them to rest of the first run or they have incomplete info
    if ([PFUser currentUser].isNew || ![[FRSDataManager sharedManager] currentUserValid]){
        
        [self navigateToNextIndex];
        
        
    }
    //User is valid and exists i.e. send them back to the app
    else{
        
        if(self.presentingViewController == nil)
            [self navigateToMainApp];
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}

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
                
                [self presentViewController:[FRSAlertViewManager
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
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [button setTitle:FACEBOOK forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:FACEBOOK] forState:UIControlStateNormal];
                    [self hideActivityIndicator];
                    [self revertScreenToNormal:self.view];
                    
                });
                
                //TODO: check if these are the strings we want
                [self presentViewController:[FRSAlertViewManager
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
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [button setTitle:TWITTER forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
                    [self revertScreenToNormal:self.view];
                    [self hideActivityIndicator];
                    
                });
                
                [self presentViewController:[FRSAlertViewManager
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

/**
 *  Reverts screen back to normal state by setting all subivews to their normal state
 *
 *  @param parentView The parent view i.e. screen to loop under
 */

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

/**
 *  Hides all view excepct the one passed
 *
 *  @param exceptionView The view not to hide
 *  @param parentView    The parent view of the exception view
 */

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
