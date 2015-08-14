#import "UIViewController+Additions.h"
#import "NotificationsViewController.h"
#import "FRSDataManager.h"
#import "FRSDataManager.h"
#import "VariableStore.h"
#import <BTBadgeView.h>

@implementation UIViewController (Additions)

#pragma mark - Utility methods

/*
** Sets up navigation bar, adds listeners for 3 notifications, and sets up notification bar button
*/

- (void)setFrescoNavigationBar
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-frescoimage"]];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.54];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAPIKeyAvailable:) name:NOTIFICATION_API_KEY_AVAILABLE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNotifications:) name:NOTIFICATION_VIEW_DISMISS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNotificationBadge:) name:NOTIFICATION_BADGE_RESET object:nil];
    
}

/*
** Sets up UI of notification bar button and clears NSUserDefaults
*/

- (void)setRightBarButtonItemWithBadge:(BOOL)badge setDisabled:(BOOL)disabled {
    
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

}


/*
** Sets up badgeView based on count of response object
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
                        
                        [[NSUserDefaults standardUserDefaults]setInteger:badgeCount forKey:UD_NOTIFICATIONS_COUNT];
                        NSLog(@"%ld", (long)badgeCount);
                    }
                }
            }];
        }
        //The notifications have been updated, and use the stored count
        else{
            
            badgeCount = [[NSUserDefaults standardUserDefaults] integerForKey:UD_NOTIFICATIONS_COUNT];

        }
        
        //Make sure the notification count is actually greater than 0, before we set it
        if(badgeCount > 0)
            badgeView.value =[NSString stringWithFormat:@"%li",  (long)badgeCount];
        
        return  badgeView;
        
    }
    
    return nil;
    
}


/*
** Toggles notification view
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

/*
** Hides notifications
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
            CATransition* transition = [CATransition animation];
            transition.duration = 0.3f;
            transition.type = kCATransitionReveal;
            transition.subtype = kCATransitionFromTop;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) - 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
            
            [notificationsController.view.layer addAnimation:transition forKey:kCATransition];
        /* End */
        
        [notificationsController willMoveToParentViewController:self];
        
        [notificationsController removeFromParentViewController];

    }

}

/*
** Shows notifications and posts notification for badge reset
*/

- (void)showNotifications {
    
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
        
        [self setRightBarButtonItemWithBadge:NO setDisabled:NO];
        
        //Retreieve Notifications View Controller from storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        NotificationsViewController *notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
        
        [self addChildViewController:notificationsController];
        
        [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) + 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];

        /* Setup Animation */
            CATransition* transition = [CATransition animation];
            transition.duration = 0.5;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromBottom;
            
            [notificationsController.view setFrame:CGRectMake(0, 0, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
            
            notificationsController.view.frame = self.view.bounds;
            [self.view addSubview:notificationsController.view];
            [notificationsController didMoveToParentViewController:self];
        
            //Commit animation by adding
            [notificationsController.view.layer addAnimation:transition forKey:kCATransition];
        /* End */
        
    }
}

#pragma mark - NSNotificationCenter Notification handling

/*
** Adds badge
*/

- (void)handleAPIKeyAvailable:(NSNotification *)notification{
    [self setRightBarButtonItemWithBadge:YES setDisabled:NO];
}

/*
** Selector for notification that removes badge
*/

- (void)resetNotificationBell:(NSNotification *)notification{
    [self setRightBarButtonItemWithBadge:NO setDisabled:YES];
}

#pragma mark - Custom Presentation and Dismiss

- (void)presentViewController:(UIViewController *)viewController withScale:(BOOL)scale{
    
    [UIView animateWithDuration:.2 animations:^{
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        self.view.alpha = 0;
    
    } completion:^(BOOL finished){
        
        [CATransaction begin];
        
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        transition.duration = 0.5f;
        transition.fillMode = kCAFillModeForwards;
        transition.removedOnCompletion = YES;
        
        [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:@"transition"];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [CATransaction setCompletionBlock: ^ {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(transition.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            });
        }];
        
        [self presentViewController:viewController animated:NO completion:nil];
        
        [CATransaction commit];
        
        self.view.alpha = 1;
    
    }];
    
}

- (void)dismissViewController:(UIViewController *)viewController withScale:(BOOL)scale{
    
    [UIView animateWithDuration:.2 animations:^{
        
        self.view.alpha = 0;
        
    } completion:^(BOOL finished){
        
        [CATransaction begin];
        
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        transition.duration = 0.5f;
        transition.fillMode = kCAFillModeForwards;
        transition.removedOnCompletion = YES;
        
        [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:@"transition"];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [CATransaction setCompletionBlock: ^ {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(transition.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            });
        }];
        
        [self dismissViewControllerAnimated:NO completion:NULL];
        
        [CATransaction commit];
        
    }];
    
}




@end
