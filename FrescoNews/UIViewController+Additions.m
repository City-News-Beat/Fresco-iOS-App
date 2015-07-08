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
    
    if([FRSDataManager sharedManager].currentUser != nil){
    
        [self setRightBarButtonItem:YES];
            
    }

}

- (void)setRightBarButtonItem:(BOOL)withBadge{
    
    UIImage *bell = [UIImage imageNamed:@"notifications"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.alpha = .54;
    
    button.bounds = CGRectMake( 0, 0, bell.size.width, bell.size.height );
    
    button.clipsToBounds = NO;
    
    [button setImage:bell forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(goToNotifications:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *notificationIcon = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:notificationIcon];
    
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
        
        [[FRSDataManager sharedManager] getNotificationsForUser:^(id responseObject, NSError *error) {
            if (!error) {
                
                [FRSDataManager sharedManager].updatedNotifications = true;
                
                if(responseObject != nil){
                    
                    NSInteger count = 0;
                    
                    for(FRSNotification *notif in responseObject){
                        
                        if(!notif.seen) count ++;
                    }
                    
                    if(count > 0)
                        badgeView.value =[NSString stringWithFormat:@"%li",  count];
                    
                }
            }

        }];
        
        return  badgeView;
        
    }
    
    return nil;
    
}


-(void)goToNotifications:(UIBarButtonItem *)sender
{
    
    if([FRSDataManager sharedManager].currentUser != nil){
    
        NotificationsViewController *notificationsController;
        
        if([self.navigationController.topViewController isKindOfClass:[NotificationsViewController class]]){
            
            CATransition* transition = [CATransition animation];
            transition.duration = 0.4f;
            transition.type = kCATransitionReveal;
            transition.subtype = kCATransitionFromTop;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.navigationController.view.layer addAnimation:transition
                                                        forKey:kCATransition];
            [self.navigationController popViewControllerAnimated:NO];
     
        }
        else{
            
            [self setRightBarButtonItem:NO];

            //Retreieve Notifications View Controller from storyboard
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
            
            [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) + 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
            
            CATransition* transition = [CATransition animation];
            transition.duration = 0.75;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromBottom;
            
            [notificationsController.view setFrame:CGRectMake(0, 0, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
            
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController pushViewController:notificationsController animated:NO];
            
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:YES];
            
        }

    }
    
}



@end
