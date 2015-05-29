#import "UIViewController+Additions.h"
#import "NotificationsViewController.h"

@implementation UIViewController (Additions)

#pragma mark - Utility methods
- (void)setFrescoNavigationBar
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-frescoimage"]];
    
    UIImage *bell = [UIImage imageNamed:@"notifications"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.alpha = .54;
    
    button.bounds = CGRectMake( 0, 0, bell.size.width, bell.size.height );
    
    [button setImage:bell forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(goToNotifications:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *notificationIcon = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:notificationIcon];
    
}

-(void)goToNotifications:(UIBarButtonItem *)sender
{
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
    NotificationsViewController *notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
    
    [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) + 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];    [UIView  beginAnimations: @"Showinfo"context: nil];
    
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:notificationsController.view cache:YES];
    
    [notificationsController.view setFrame:CGRectMake(0, 0, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
    
    [UIView commitAnimations];
    
    [self.navigationController pushViewController:notificationsController animated:NO];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:YES];
    
}



@end
