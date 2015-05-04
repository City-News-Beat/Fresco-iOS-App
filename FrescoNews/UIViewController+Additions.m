#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

#pragma mark - Utility methods
- (void)setFrescoImageHeader
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-frescoimage"]];
}
@end
