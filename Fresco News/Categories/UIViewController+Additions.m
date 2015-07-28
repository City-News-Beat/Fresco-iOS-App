#import "UIViewController+Additions.h"
#import "NotificationsViewController.h"
#import "FRSDataManager.h"
#import "FRSDataManager.h"
#import "VariableStore.h"
#import <BTBadgeView.h>

@implementation UIViewController (Additions)

#pragma mark - Utility methods

- (void)setFrescoNavigationBar
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-frescoimage"]];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.54];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAPIKeyAvailable:) name:kNotificationAPIKeyAvailable object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNotifications:) name:kNotificationViewDismiss object:nil];
}

- (void)setRightBarButtonItem:(BOOL)withBadge{
    
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
    if(withBadge && [FRSDataManager sharedManager].updatedNotifications == false){
      
        [self.navigationItem.rightBarButtonItem.customView addSubview:[self getBadgeView]];
        
    }

}

- (BTBadgeView *)getBadgeView
{
    
    if([FRSDataManager sharedManager].currentUser != nil){
    
        BTBadgeView *badgeView = [[BTBadgeView alloc] initWithFrame:CGRectMake(4,-8, 30, 20)];
        
        badgeView.layer.cornerRadius = 10;
        
        badgeView.shadow = NO;
        
        badgeView.clipsToBounds = NO;
        
        badgeView.strokeColor = [UIColor whiteColor];
        
        badgeView.fillColor = [UIColor whiteColor];
        
        badgeView.textColor = [UIColor blackColor];
        
        badgeView.strokeWidth = 0;
        
        badgeView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        
        [[FRSDataManager sharedManager] getNotificationsForUser:0 withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                if(responseObject != nil){
                    
                    NSInteger count = 0;
                    
                    for(FRSNotification *notif in responseObject){
                        
                        if(!notif.seen) count ++;
                    }
                    
                    if(count > 0)
                        badgeView.value =[NSString stringWithFormat:@"%li",  (long)count];
                    
                }
            }

        }];
        
        return  badgeView;
        
    }
    
    return nil;
    
}

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
    
    if(exists){
    
        NotificationsViewController *notificationsController = [self.childViewControllers objectAtIndex:count];
        
        [notificationsController setAllNotificaitonsSeen];
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromTop;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) - 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
        
        [notificationsController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        
        [notificationsController willMoveToParentViewController:self];
        
        [notificationsController removeFromParentViewController];

    }

}


- (void)showNotifications{
    
    if([[FRSDataManager sharedManager] isLoggedIn]){
        
        [self setRightBarButtonItem:NO];
        
        //Retreieve Notifications View Controller from storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        NotificationsViewController *notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
        
        [self addChildViewController:notificationsController];
        
        [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) + 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];

        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromBottom;
        
        [notificationsController.view setFrame:CGRectMake(0, 0, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
        
        notificationsController.view.frame = self.view.bounds;
        [self.view addSubview:notificationsController.view];
        [notificationsController didMoveToParentViewController:self];
        
        [notificationsController.view.layer addAnimation:transition forKey:kCATransition];
        
    }
}

#pragma mark - NSNotificationCenter Notification handling

- (void)handleAPIKeyAvailable:(NSNotification *)notification
{
    [self setRightBarButtonItem:YES];
}

@end
