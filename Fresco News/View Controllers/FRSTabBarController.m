//
//  FRSTabBarController.m
//  Fresco
//
//  Created by Danny Boy Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSTabBarController.h"
#import "FRSOnboardingViewController.h"
#import "FRSNavigationController.h"
#import "FRSProfileViewController.h"
#import "FRSHomeViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSStoriesViewController.h"
#import "FRSCameraViewController.h"
#import "UIColor+Fresco.h"
#import "FRSNavigationBar.h"
#import "FRSAppDelegate.h"
#import "FRSUserNotificationViewController.h"

@interface FRSTabBarController () <UITabBarControllerDelegate>

@property (strong, nonatomic) UIView *cameraBackgroundView;

@end

@implementation FRSTabBarController


-(void)presentAssignments {
    
}
-(void)returnToGalleryPost {
    
}

-(void)respondToQuickAction:(NSString *)quickAction {
    if ([quickAction isEqualToString:assignmentsAction]) {
        // open assignments
        [self setSelectedIndex:3];
    }
    else if ([quickAction isEqualToString:takePhotoAction]) {
        // open camera, switch to photo
        [self setSelectedIndex:2];
    }
    else if ([quickAction isEqualToString:takeVideoAction]) {
        // just open camera
        [self setSelectedIndex:2];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UITabBar appearance] setBackgroundColor:[UIColor frescoTabBarColor]];

    [self configureAppearance];
    [self configureViewControllers];
    
    [self configureTabBarItems];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        
        vc.title = nil;
//        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }];
    
    [self configureIrisItem];
    // Do any additional setup after loading the view.
}

-(void)configureAppearance{
    [self.tabBar setBarTintColor:[UIColor frescoTabBarColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)configureTabBarItems{
    
    UITabBarItem *item0 = [self.tabBar.items objectAtIndex:0];
    item0.image = [[UIImage imageNamed:@"tab-bar-home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.selectedImage = [[UIImage imageNamed:@"tab-bar-home-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item1 = [self.tabBar.items objectAtIndex:1];
    item1.image = [[UIImage imageNamed:@"tab-bar-story"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [[UIImage imageNamed:@"tab-bar-story-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item2 = [self.tabBar.items objectAtIndex:2];
    item2.image = [[UIImage imageNamed:@"tab-bar-iris"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [[UIImage imageNamed:@"tab-bar-iris"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item3 = [self.tabBar.items objectAtIndex:3];
    item3.image = [[UIImage imageNamed:@"tab-bar-assign"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.selectedImage = [[UIImage imageNamed:@"tab-bar-assign-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item4 = [self.tabBar.items objectAtIndex:4];
    item4.image = [[UIImage imageNamed:@"tab-bar-profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.selectedImage = [[UIImage imageNamed:@"tab-bar-profile-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    
    //Image insets are hard coded to follow the spec
    
    CGFloat notificationDotXOffset;
    
    if (IS_IPHONE_6) {
        item0.imageInsets = UIEdgeInsetsMake(5, 6, -5, -6);
        item1.imageInsets = UIEdgeInsetsMake(5, -7, -5, 7);
        item2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item3.imageInsets = UIEdgeInsetsMake(5, 7, -5, -7);
        item4.imageInsets = UIEdgeInsetsMake(5, -6, -5, 6);
        notificationDotXOffset = 30.5;
    } else if (IS_IPHONE_6_PLUS) {
        item0.imageInsets = UIEdgeInsetsMake(5, 7, -5, -7);
        item1.imageInsets = UIEdgeInsetsMake(5, -8, -5, 8);
        item2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item3.imageInsets = UIEdgeInsetsMake(5, 8, -5, -8);
        item4.imageInsets = UIEdgeInsetsMake(5, -7, -5, 7);
        notificationDotXOffset = 35;
    } else if (IS_IPHONE_5) {
        item0.imageInsets = UIEdgeInsetsMake(5, 5, -5, -5);
        item1.imageInsets = UIEdgeInsetsMake(5, -5, -5, 5);
        item2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item3.imageInsets = UIEdgeInsetsMake(5, 5, -5, -5);
        item4.imageInsets = UIEdgeInsetsMake(5, -5, -5, 5);
        notificationDotXOffset = 23;
    }

    //if (unreadNotificationCount >= 1) {
    item4.image = [[UIImage imageNamed:@"tab-bar-bell"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.selectedImage = [[UIImage imageNamed:@"tab-bar-bell-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.title = @"";
    
    self.dot = [[UIView alloc] initWithFrame:CGRectMake(self.tabBar.frame.size.width - 9 - notificationDotXOffset, self.tabBar.frame.size.height - 9 - 10.5, 9, 9)]; //10.5 y value coming from spec, adding 2px to w/h for borderWidth
    self.dot.layer.masksToBounds = YES;
    self.dot.layer.cornerRadius = 9/2;
    self.dot.backgroundColor = [UIColor frescoTabBarColor];
    self.dot.layer.zPosition = 1;
    self.dot.userInteractionEnabled = NO;
    [self.tabBar addSubview:self.dot];
    
    UIView *yellowCircle = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 7, 7)];
    yellowCircle.backgroundColor = [UIColor frescoOrangeColor];
    yellowCircle.layer.cornerRadius = 3.5;
    [self.dot addSubview:yellowCircle];
    //}
}

-(void)configureViewControllers {
    UINavigationController *vc = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc pushViewController:[[FRSHomeViewController alloc] init] animated:NO];
    
    UINavigationController *vc1 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc1 pushViewController:[[FRSStoriesViewController alloc] init] animated:NO];
    
    UIViewController *vc2 = [UIViewController new];
    vc2.view.backgroundColor = [UIColor blackColor];
    UINavigationController *vc3 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc3 pushViewController:[[FRSAssignmentsViewController alloc] init] animated:NO];
    
    UINavigationController *vc4 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc4 pushViewController:[[FRSProfileViewController alloc] initWithUser:[[FRSAPIClient sharedClient] authenticatedUser]] animated:NO];
    
    self.viewControllers = @[vc, vc1, vc2, vc3, vc4];
}

-(void)configureIrisItem {
    
    CGFloat origin = self.view.frame.size.width * 2/5;
    CGFloat width = self.view.frame.size.width/5;
    
    self.cameraBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(origin, 0, width, 50)];
    self.cameraBackgroundView.backgroundColor = [UIColor frescoOrangeColor];
    [self.tabBar insertSubview:self.cameraBackgroundView atIndex:0];
}

-(void)setIrisItemColor:(UIColor *)color {
    self.cameraBackgroundView.backgroundColor = color;
}

#pragma mark Delegate

-(void)updateUserIcon {
    UITabBarItem *item4 = [self.tabBar.items objectAtIndex:4];
    item4.image = [[UIImage imageNamed:@"tab-bar-profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.selectedImage = [[UIImage imageNamed:@"tab-bar-profile-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    FRSTabBarController *frsTabBar = (FRSTabBarController *)self.tabBarController;
    frsTabBar.dot.alpha = 0;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    item.title = @"";
    
    if ([self.tabBar.items indexOfObject:item] == 2) {
        FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
        UINavigationController *navControl = [[UINavigationController alloc] init];
        navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
        [navControl pushViewController:cam animated:NO];
        [navControl setNavigationBarHidden:YES];
        
        [self presentViewController:navControl animated:YES completion:^{
            [self setSelectedIndex:self.lastActiveIndex];
        }];
    }
    
    if ([self.tabBar.items indexOfObject:item] == 4) {
        
        if (![[FRSAPIClient sharedClient] isAuthenticated]) {
            FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
            [self.navigationController pushViewController:onboardVC animated:NO];
        } else {
            
            
            UINavigationController *profileNav = (UINavigationController *)self.viewControllers[[self.tabBar.items indexOfObject:item]];
            FRSProfileViewController *profile = (FRSProfileViewController *)[[profileNav viewControllers] firstObject];
            [profile loadAuthenticatedUser];
            
            
//            if (userNotificationCount >= 1) {
                profile.shouldShowNotificationsOnLoad = YES;
            //userNotificationCount resets once the vc is loaded
            //else gets called when user tabs back on the tab bar
//            } else {
//                [self updateUserIcon];
//            }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    // UD_PREVIOUSLY_SELECTED_TAB = tabBarController.selectedIndex;
    UIViewController *selectedVC = viewController;
    if ([viewController isKindOfClass:[FRSNavigationController class]]){
        FRSNavigationController *nav = (FRSNavigationController *)viewController;
        selectedVC = [nav.viewControllers firstObject];
    }
    
    self.lastActiveIndex = tabBarController.selectedIndex;
    
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    
    switch (index) {
        case 0:{
            
            if (self.lastActiveIndex != 0) {
                break;
            }
            
            FRSHomeViewController *homeVC = (FRSHomeViewController *)selectedVC;
            [homeVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            
        } break;
            
        case 1:{
            
            if (self.lastActiveIndex != 1) {
                break;
            }
            
            FRSStoriesViewController *storiesVC = (FRSStoriesViewController *)selectedVC;
            [storiesVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            
        } break;
            
        case 2:
            return NO;
            
        case 3:
            
            if (self.lastActiveIndex == 3){
                if (![selectedVC isKindOfClass:[FRSAssignmentsViewController class]]) break;
                FRSAssignmentsViewController *assignVC = (FRSAssignmentsViewController *)selectedVC;
                [assignVC setInitialMapRegion];
                
            } break;
            
        case 4:{
            
            if ([[FRSAPIClient sharedClient] isAuthenticated]) {
                FRSProfileViewController *profileVC = (FRSProfileViewController *)selectedVC;
                [profileVC.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            } else {
                return NO;
            }
            
            //if (userNotificationCount >= 1) {
            FRSUserNotificationViewController *notificationVC = [[FRSUserNotificationViewController alloc] init];
            [self.navigationController pushViewController:notificationVC animated:NO];
            //FRSUserNotificationViewController *profileVC = (FRSUserNotificationViewController *)selectedVC;
            //[profileVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            
            //}

            if (self.lastActiveIndex != 4) {
                break;
            }

            
        } break;
            
        default:
            break;
    }
    
    
    return YES;
}

-(void)handleNotification:(NSDictionary *)notification {
    
}

-(void)openGalleryID:(NSString *)galleryID {
    
}

-(void)openStoryID:(NSString *)storyID {
    
}

-(void)openUserID:(NSString *)userID {
    
}

-(void)openGalleryIDS:(NSArray *)galleryIDS {
    
}

-(void)openAssignmentID:(NSString *)assignmentID {
    
}

@end
