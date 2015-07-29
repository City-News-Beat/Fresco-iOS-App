@import Foundation;

@interface UIViewController (RelativeDate)

- (void)setFrescoNavigationBar;

-(void)goToNotifications:(UIBarButtonItem *)sender;

- (void)hideNotifications:(NSNotification *)notification;

- (void)setRightBarButtonItemWithBadge:(BOOL)badge;
@end
