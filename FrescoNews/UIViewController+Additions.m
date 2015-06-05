#import "UIViewController+Additions.h"
#import "NotificationsViewController.h"
#import "FRSDataManager.h"

@implementation UIViewController (Additions)

#pragma mark - Utility methods
- (void)setFrescoNavigationBar
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-frescoimage"]];
    
    if([FRSDataManager sharedManager].currentUser != nil){
    
        UIImage *bell = [UIImage imageNamed:@"notifications"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.alpha = .54;
        
        button.bounds = CGRectMake( 0, 0, bell.size.width, bell.size.height );
        
        [button setImage:bell forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(goToNotifications:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *notificationIcon = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        [self.navigationItem setRightBarButtonItem:notificationIcon];
        
    }
    
}

-(void)goToNotifications:(UIBarButtonItem *)sender
{
    
    if([FRSDataManager sharedManager].currentUser != nil){
    
        NotificationsViewController *notificationsController;
        
        if([self.navigationController.topViewController isKindOfClass:[NotificationsViewController class]]){
            
            [[self navigationController] popViewControllerAnimated:YES];
            
        }
        else{
            
            //Retreieve Notifications View Controller from storyboard
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
            
    //        [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) + 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];    [UIView  beginAnimations: @"Showinfo"context: nil];
    //        
    //        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    //        [UIView setAnimationDuration:0.75];
    //        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:notificationsController.view cache:YES];
    //        
    //        [notificationsController.view setFrame:CGRectMake(0, 0, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
    //        
    //        [UIView commitAnimations];
            
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:YES];
            [self.navigationController pushViewController:notificationsController animated:YES];
            
        }

    }
    

    

}



@end
