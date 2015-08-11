@import Foundation;

@interface UIViewController (RelativeDate)

- (void)setFrescoNavigationBar;

- (void)goToNotifications:(UIBarButtonItem *)sender;

- (void)hideNotifications:(NSNotification *)notification;

- (void)setRightBarButtonItemWithBadge:(BOOL)badge;

- (void)presentViewController:(UIViewController *)viewController withScale:(BOOL)scale;

- (void)dismissViewController:(UIViewController *)viewController withScale:(BOOL)scale;

@end
