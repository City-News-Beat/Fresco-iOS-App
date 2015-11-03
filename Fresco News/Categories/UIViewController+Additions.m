//
//  UIViewController+Additions.m
//  Fresco
//
//  Created by Fresco News on 9/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIViewController+Additions.h"
#import "NotificationsViewController.h"
#import "FRSDataManager.h"
#import "FRSDataManager.h"
#import <BTBadgeView.h>

@implementation UIViewController (Additions)

#pragma mark - Utility methods

/**
 *  Sets up navigation bar, adds listeners for 3 notifications, and sets up notification bar button
 */

- (void)setFrescoNavigationBar
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-frescoimage"]];
    
    self.navigationController.navigationBar.tintColor = [UIColor textHeaderBlackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAPIKeyAvailable:) name:NOTIF_API_KEY_AVAILABLE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNotifications:) name:NOTIF_VIEW_DISMISS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNotificationBell:) name:NOTIF_BADGE_RESET object:nil];
    
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
    
        [self setRightBarButtonItemWithBadge:YES setDisabled:NO];
        
    }
    
}


/**
 *  Sets up UI of notification bar button and clears NSUserDefaults
 *
 *  @param badge    To add a badge or not
 *  @param disabled to disable the bar button or not
 */

- (void)setRightBarButtonItemWithBadge:(BOOL)badge setDisabled:(BOOL)disabled {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(disabled){
            
            [self.navigationItem setRightBarButtonItem:nil];
            
        }
        else{
            
            UIImage *bell = [UIImage imageNamed:@"notifications"];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            button.alpha = .54;
            
            button.bounds = CGRectMake( 0, 0, bell.size.width, bell.size.height );
            
            button.clipsToBounds = NO;
            
            [button setImage:bell forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(toggleNotifications:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *notificationIcon = [[UIBarButtonItem alloc] initWithCustomView:button];
            
            [self.navigationItem setRightBarButtonItem:notificationIcon];
            
            //Set the badge on the notification bell
            if(badge) {
                [self.navigationItem.rightBarButtonItem.customView addSubview:[self getBadgeView]];
                
            } else {
                
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"notificationsCount"] > 0) {
                    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"notificationsCount"];
                }
            }
            
        }
        
    });

}


/**
 *  Sets up badgeView based on count of response object
 *
 *  @return Returns a badge view for the bell
 */

- (BTBadgeView *)getBadgeView {
    
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
    
        BTBadgeView *badgeView = [[BTBadgeView alloc] initWithFrame:CGRectMake(4,-8, 30, 20)];
        
        badgeView.layer.cornerRadius = 10;
        
        badgeView.shadow = NO;
        
        badgeView.clipsToBounds = NO;
        
        badgeView.strokeColor = [UIColor whiteColor];
        
        badgeView.fillColor = [UIColor whiteColor];
        
        badgeView.textColor = [UIColor blackColor];
        
        badgeView.strokeWidth = 0;
        
        badgeView.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:12.0];
        
        __block NSInteger badgeCount = 0;
        
        //If the notifications haven't been updated yet, then retrieve them and store the count
        if(![FRSDataManager sharedManager].updatedNotifications) {
            
            [[FRSDataManager sharedManager] getNotificationsForUser:0 withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    if ([responseObject count] > 0) {

                        for(FRSNotification *notif in responseObject){
                            
                            if(!notif.seen) badgeCount ++;
                        }
                        
                    }
                }
            }];
        }
        
        //Make sure the notification count is actually greater than 0, before we set it
        if(badgeCount > 0)
            badgeView.value =[NSString stringWithFormat:@"%li",  (long)badgeCount];
        
        return  badgeView;
        
    }
    
    return nil;
    
}


/**
 *  Toggles notification view
 *
 *  @param sender Sender object
 */

- (void)toggleNotifications:(UIBarButtonItem*)sender{
    
    BOOL exists = false;
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[NotificationsViewController class]]) {
            exists = true;
        }
    }
    
    if(exists)
        [self hideNotifications:nil];
    else
        [self showNotifications];
}

/**
 *  Hides notifications
 *
 *  @param notification <#notification description#>
 */

- (void)hideNotifications:(NSNotification *)notification{
    
    BOOL exists = NO;
    
    NSUInteger count = 0;
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[NotificationsViewController class]]) {
            exists = YES;
            break;
        }
        count ++;
    }
    
    if (exists) {
        
        NotificationsViewController *notificationsController = [self.childViewControllers objectAtIndex:count];
        
        //Data call to set the notification status as 'seen'
        [notificationsController setAllNotificaitonsSeen];
        
        /* Animation Setup */
        [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) - 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
            
        } completion:^(BOOL finished) {
            [notificationsController.view removeFromSuperview];
            [notificationsController willMoveToParentViewController:self];
            [notificationsController removeFromParentViewController];
        }];
    
    }
    
    //Running this check because we have to present the view on top of a UITableViewController in the stories tab
    if([self isKindOfClass:[UITableViewController class]]){
        ((UITableViewController *)self).tableView.scrollEnabled = YES;
    }
    
}

/**
 *  Shows notifications and posts notification for badge reset
 */

- (void)showNotifications {
    
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
        
        [self setRightBarButtonItemWithBadge:NO setDisabled:NO];
        
        //Retreieve Notifications View Controller from storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        NotificationsViewController *notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
        
        if([self isKindOfClass:[UITableViewController class]]){
            ((UITableViewController *)self).tableView.scrollEnabled = NO;
        }
        
        [self addChildViewController:notificationsController];
        
        //Preset frame higher to slide down
        [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height), notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
        [self.view addSubview:notificationsController.view];
        
        [UIView animateWithDuration:.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
            notificationsController.view.frame = self.view.bounds;
            [self.view bringSubviewToFront:notificationsController.view];
            [notificationsController didMoveToParentViewController:self];
        
        } completion:nil];
    }
}

#pragma mark - NSNotificationCenter / KVO

/**
 *  Adds badge to nav bar
 *
 *  @param notification <#notification description#>
 */

- (void)handleAPIKeyAvailable:(NSNotification *)notification{

    [self setRightBarButtonItemWithBadge:YES setDisabled:NO];

}

/**
 *  Selector for notification that removes badge
 *
 *  @param notification <#notification description#>
 */

- (void)resetNotificationBell:(NSNotification *)notification{
    
    [self setRightBarButtonItemWithBadge:NO setDisabled:YES];
    
}



@end