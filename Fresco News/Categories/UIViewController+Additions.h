@import Foundation;

@interface UIViewController (Additions)

- (void)setFrescoNavigationBar;

- (void)showNotifications;

- (void)hideNotifications:(NSNotification *)notification;

- (void)setRightBarButtonItemWithBadge:(BOOL)badge setDisabled:(BOOL)disabled;

- (void)presentViewController:(UIViewController *)viewController withScale:(BOOL)scale;

- (void)dismissViewController:(UIViewController *)viewController withScale:(BOOL)scale;

@end
