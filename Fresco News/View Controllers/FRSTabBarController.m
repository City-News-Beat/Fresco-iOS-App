//
//  FRSTabBarController.m
//  Fresco
//
//  Created by Danny Boy Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSTabBarController.h"
#import "FRSAppDelegate.h"

/* VIEW CONTROLLERS */
#import "FRSBaseViewController.h"
#import "FRSOnboardingViewController.h"
#import "FRSNavigationController.h"
#import "FRSHomeViewController.h"
#import "FRSStoriesViewController.h"
#import "FRSCameraViewController.h"
#import "UIColor+Fresco.h"
#import "FRSNavigationBar.h"
#import "FRSAssignmentsViewController.h"
#import "FRSProfileViewController.h"
#import "FRSUserNotificationViewController.h"

/* MANAGERS */
#import "FRSLocationManager.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSAssignmentManager.h"

/* UI */
#import "FRSPermissionAlertView.h"
#import "FRSNavigationBar.h"
#import "FRSIndicatorDot.h"
#import "UIColor+Fresco.h"


@interface FRSTabBarController () <UITabBarControllerDelegate>

@property (strong, nonatomic) UIView *cameraBackgroundView;
@property (strong, nonatomic) UIImage *bellImage;
@property (strong, nonatomic) FRSLocationManager *locationManager;
@property CGFloat xOffset;

@end

@implementation FRSTabBarController

- (void)respondToQuickAction:(NSString *)quickAction {
    if ([quickAction isEqualToString:assignmentsAction]) {
        // open assignments
        [self setSelectedIndex:3];
    } else if ([quickAction isEqualToString:takePhotoAction]) {
        // open camera, switch to photo
        //        [FRSTracker track:@"Camera Opened"];

        FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
        UINavigationController *navControl = [[UINavigationController alloc] init];
        navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
        [navControl pushViewController:cam animated:NO];
        [navControl setNavigationBarHidden:YES];
        [self presentViewController:navControl
                           animated:YES
                         completion:^{

                         }];

    } else if ([quickAction isEqualToString:takeVideoAction]) {
        // just open camera
        //        [FRSTracker track:@"Camera Opened"];

        FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
        UINavigationController *navControl = [[UINavigationController alloc] init];
        navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
        [navControl pushViewController:cam animated:NO];
        [navControl setNavigationBarHidden:YES];

        [self presentViewController:navControl
                           animated:YES
                         completion:^{

                         }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;

    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundColor:[UIColor frescoTabBarColor]];

    [self configureAppearance];
    [self configureViewControllersWithNotif:NO];
    [self configureTabBarItems];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
      vc.title = nil;
    }];
    [self configureIrisItem];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assignmentAccepted:) name:enableAssignmentAccept object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableAssignmentAccept:) name:disableAssignmentAccept object:nil];
    
    // Creating a reference to the bell image here to check when user taps on button.
    self.bellImage = [[UIImage imageNamed:@"tab-bar-bell"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self checkNewAssignments];
}

- (void)assignmentAccepted:(NSNotification *)assignment {
    self.cameraBackgroundView.backgroundColor = [UIColor frescoGreenColor];
}

- (void)disableAssignmentAccept:(NSNotification *)assignment {
    self.cameraBackgroundView.backgroundColor = [UIColor frescoOrangeColor];
}

- (void)configureAppearance {
    [self.tabBar setBarTintColor:[UIColor frescoTabBarColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)configureTabBarItems {

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

    if (IS_IPHONE_6) {
        item0.imageInsets = UIEdgeInsetsMake(5, 6, -5, -6);
        item1.imageInsets = UIEdgeInsetsMake(5, -7, -5, 7);
        item2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item3.imageInsets = UIEdgeInsetsMake(5, 7, -5, -7);
        item4.imageInsets = UIEdgeInsetsMake(5, -6, -5, 6);
        self.xOffset = 40;
    } else if (IS_IPHONE_6_PLUS) {
        item0.imageInsets = UIEdgeInsetsMake(5, 7, -5, -7);
        item1.imageInsets = UIEdgeInsetsMake(5, -8, -5, 8);
        item2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item3.imageInsets = UIEdgeInsetsMake(5, 8, -5, -8);
        item4.imageInsets = UIEdgeInsetsMake(5, -7, -5, 7);
        self.xOffset = 45;
    } else if (IS_IPHONE_5) {
        item0.imageInsets = UIEdgeInsetsMake(5, 5, -5, -5);
        item1.imageInsets = UIEdgeInsetsMake(5, -5, -5, 5);
        item2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item3.imageInsets = UIEdgeInsetsMake(5, 5, -5, -5);
        item4.imageInsets = UIEdgeInsetsMake(5, -5, -5, 5);
        self.xOffset = 33;
    }

    //if (unreadNotificationCount >= 1) {
    //    item4.image = [[UIImage imageNamed:@"tab-bar-bell"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    item4.selectedImage = [[UIImage imageNamed:@"tab-bar-bell-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    item4.title = @"";
    //
    //    self.dot = [[UIView alloc] initWithFrame:CGRectMake(self.tabBar.frame.size.width - 9 - notificationDotXOffset, self.tabBar.frame.size.height - 9 - 10.5, 9, 9)]; //10.5 y value coming from spec, adding 2px to w/h for borderWidth
    //    self.dot.layer.masksToBounds = YES;
    //    self.dot.layer.cornerRadius = 9/2;
    //    self.dot.backgroundColor = [UIColor frescoTabBarColor];
    //    self.dot.layer.zPosition = 1;
    //    self.dot.userInteractionEnabled = NO;
    //    [self.tabBar addSubview:self.dot];
    //
    //    UIView *yellowCircle = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 7, 7)];
    //    yellowCircle.backgroundColor = [UIColor frescoOrangeColor];
    //    yellowCircle.layer.cornerRadius = 3.5;
    //    [self.dot addSubview:yellowCircle];
    //}
}

- (void)configureViewControllersWithNotif:(BOOL)notif {
    UINavigationController *vc = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc pushViewController:[[FRSHomeViewController alloc] init] animated:NO];

    UINavigationController *vc1 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc1 pushViewController:[[FRSStoriesViewController alloc] init] animated:NO];

    UIViewController *vc2 = [UIViewController new];
    vc2.view.backgroundColor = [UIColor blackColor];
    UINavigationController *vc3 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [vc3 pushViewController:[[FRSAssignmentsViewController alloc] init] animated:NO];

    if (notif) {
        UINavigationController *vc4 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
        [vc4 pushViewController:[[FRSUserNotificationViewController alloc] init] animated:NO];
        self.viewControllers = @[ vc, vc1, vc2, vc3, vc4 ];
    } else {
        UINavigationController *vc4 = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
        [vc4 pushViewController:[[FRSProfileViewController alloc] initWithUser:[[FRSUserManager sharedInstance] authenticatedUser]] animated:NO];
        self.viewControllers = @[ vc, vc1, vc2, vc3, vc4 ];
    }
}

- (void)configureIrisItem {

    CGFloat origin = self.view.frame.size.width * 2 / 5;
    CGFloat width = self.view.frame.size.width / 5;

    self.cameraBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(origin, 0, width, 50)];
    self.cameraBackgroundView.backgroundColor = [UIColor frescoOrangeColor];
    [self.tabBar insertSubview:self.cameraBackgroundView atIndex:0];
}

- (void)setIrisItemColor:(UIColor *)color {
    self.cameraBackgroundView.backgroundColor = color;
}

- (void)checkLocationAndPresentPermissionsAlert {
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
        FRSPermissionAlertView *alert = [[FRSPermissionAlertView alloc] initWithLocationManagerDelegate:self.locationManager];
        [alert show];
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.didPresentPermissionsRequest = YES;
    }
}

- (void)presentCameraPermissionsAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
      FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"HOLD UP" message:@"We need permission to access your camera, microphone, and camera. Head over to Settings and make sure these are all enabled to continue." actionTitle:@"ASK LATER" cancelTitle:@"SETTINGS" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
      [alert show];
    });
}

- (void)didPressButton:(FRSAlertView *)alertView atIndex:(NSInteger)index {
    if (index == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (AVAuthorizationStatus)cameraAuthStatus {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus;
}

- (AVAuthorizationStatus)microphoneAuthStatus {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return authStatus;
}

- (PHAuthorizationStatus)photoLibraryAuthStatus {
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    return authStatus;
}

- (void)scrollToTop {
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    item.title = @"";

    if ([self.tabBar.items indexOfObject:item] == 2) {
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
            FRSPermissionAlertView *alert = [[FRSPermissionAlertView alloc] initWithLocationManagerDelegate:self.locationManager];
            [alert show];
            FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.didPresentPermissionsRequest = YES;
            return;
        }

        //If not determined, request and return
        if ([self cameraAuthStatus] == AVAuthorizationStatusDenied || [self cameraAuthStatus] == AVAuthorizationStatusNotDetermined || [self microphoneAuthStatus] == AVAuthorizationStatusDenied || [self microphoneAuthStatus] == AVAuthorizationStatusNotDetermined || [self photoLibraryAuthStatus] == PHAuthorizationStatusDenied || [self photoLibraryAuthStatus] == PHAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                       if (granted) {
                                           //If camera granted, request Audio
                                           [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                                                    completionHandler:^(BOOL granted) {
                                                                      if (granted) {
                                                                          //If audio granted, request photo library
                                                                          [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                                                            if (status == PHAuthorizationStatusAuthorized) {
                                                                                [self presentCameraViewController];
                                                                            } else {
                                                                                //If photo library is not granted, present alert
                                                                                [self presentCameraPermissionsAlert];
                                                                            }
                                                                          }];
                                                                      } else {
                                                                          //If photo library is not granted, present alert
                                                                          [self presentCameraPermissionsAlert];
                                                                      }
                                                                    }];
                                       } else {
                                           //If camera is not granted, present alert
                                           [self presentCameraPermissionsAlert];
                                       }
                                     }];
            return;
        } else {
            [self presentCameraViewController];
        }

        //If denied or not determined, present alert
        if ([self cameraAuthStatus] == AVAuthorizationStatusDenied || [self cameraAuthStatus] == AVAuthorizationStatusNotDetermined || [self microphoneAuthStatus] == AVAuthorizationStatusDenied || [self microphoneAuthStatus] == AVAuthorizationStatusNotDetermined || [self photoLibraryAuthStatus] == PHAuthorizationStatusDenied || [self photoLibraryAuthStatus] == PHAuthorizationStatusNotDetermined) {
            [self presentCameraPermissionsAlert];
            return;
        } else {
            [self presentCameraViewController];
        }
    }

    if ([self.tabBar.items indexOfObject:item] == 4) {
        if ([[self.tabBar.items objectAtIndex:4].image isEqual:self.bellImage]) {
            UINavigationController *profileNav = (UINavigationController *)self.viewControllers[[self.tabBar.items indexOfObject:item]];
            FRSProfileViewController *profile = (FRSProfileViewController *)[[profileNav viewControllers] firstObject];
            /*profile.shouldShowNotificationsOnLoad = YES;
                 [profile loadAuthenticatedUser]; */
            [profile showNotificationsNotAnimated];

        } else {
            if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
                id<FRSApp> appDelegate = (id<FRSApp>)[[UIApplication sharedApplication] delegate];
                FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
                UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

                if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
                    [navController pushViewController:onboardVC animated:FALSE];
                } else {
                    UITabBarController *tab = (UITabBarController *)navController;
                    tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
                    tab.navigationController.interactivePopGestureRecognizer.delegate = nil;
                    UINavigationController *onboardNav = [[FRSNavigationController alloc] init];
                    [onboardNav pushViewController:onboardVC animated:NO];
                    [tab presentViewController:onboardNav animated:YES completion:Nil];
                }
            } else {
                UINavigationController *profileNav = (UINavigationController *)self.viewControllers[[self.tabBar.items indexOfObject:item]];
                if (profileNav.viewControllers.count == 2) {
                    [profileNav popViewControllerAnimated:YES];
                } else {
                    FRSProfileViewController *profile = (FRSProfileViewController *)[[profileNav viewControllers] firstObject];
                    [profile loadAuthenticatedUser];
                }
            }
        }
    }
}

- (void)presentCameraViewController {
    //    [FRSTracker track:@"Camera Opened"];

    FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
    UINavigationController *navControl = [[UINavigationController alloc] init];
    navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    [navControl pushViewController:cam animated:NO];
    [navControl setNavigationBarHidden:YES];

    [self presentViewController:navControl
                       animated:YES
                     completion:^{
                       [self setSelectedIndex:self.lastActiveIndex];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if (viewController == self.selectedViewController) {
        if ([viewController respondsToSelector:@selector(scrollToTop)]) {
            [viewController performSelector:@selector(scrollToTop)];
        }
    }

    // UD_PREVIOUSLY_SELECTED_TAB = tabBarController.selectedIndex;
    UIViewController *selectedVC = viewController;
    if ([viewController isKindOfClass:[FRSNavigationController class]]) {
        FRSNavigationController *nav = (FRSNavigationController *)viewController;
        selectedVC = [nav.viewControllers firstObject];
    }

    self.lastActiveIndex = tabBarController.selectedIndex;

    NSInteger index = [self.viewControllers indexOfObject:viewController];
    [FRSIndicatorDot removeDotInView:self.tabBar atIndex:index]; // We may want to specify when we remove the notification dot in the future. For example, if accessing 'new content' when it's not directly in the view controller (global assignments).
    switch (index) {
    case 0: {

        if (self.lastActiveIndex != 0) {
            break;
        }

        FRSHomeViewController *homeVC = (FRSHomeViewController *)selectedVC;
        [homeVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];

    } break;

    case 1: {

        if (self.lastActiveIndex != 1) {
            break;
        }

        FRSStoriesViewController *storiesVC = (FRSStoriesViewController *)selectedVC;
        [storiesVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];

    } break;

    case 2:
        return NO;

    case 3:
        if (self.lastActiveIndex == 3) {
            if (![selectedVC isKindOfClass:[FRSAssignmentsViewController class]])
                break;
            FRSAssignmentsViewController *assignVC = (FRSAssignmentsViewController *)selectedVC;
            [assignVC setInitialMapRegion];

            // used to delay map tracking until map region has been animated to user location
            // avoid multiple map animation calls (causes minor zoom issues)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              assignVC.mapShouldFollowUser = YES;
            });
        }
        break;

    case 4: {
        
        [self showBell:NO];
        
        if (self.lastActiveIndex == 4) {
            FRSProfileViewController *profileVC = (FRSProfileViewController *)selectedVC;
            [profileVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            return NO;
        }
        if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
            FRSProfileViewController *profileVC = (FRSProfileViewController *)selectedVC;
            [profileVC.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        } else {
            return NO;
        }

        if (self.lastActiveIndex != 4) {
            break;
        }
        //if (userNotificationCount >= 1) {
        //            FRSUserNotificationViewController *notificationVC = [[FRSUserNotificationViewController alloc] init];
        //            [self.navigationController pushViewController:notificationVC animated:NO];
        //            FRSUserNotificationViewController *profileVC = (FRSUserNotificationViewController *)selectedVC;
        //            [profileVC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];

        //}

    } break;

    default:
        break;
    }

    return YES;
}

-(void)checkNewAssignments {
    
    CLLocation *location = [[FRSLocator sharedLocator] currentLocation];
    
    [[FRSAssignmentManager sharedInstance] getAssignmentsWithinRadius:20 ofLocation:@[ @(location.coordinate.longitude), @(location.coordinate.latitude) ] withCompletion:^(id responseObject, NSError *error) {
        NSArray *assignments = (NSArray *)responseObject[@"nearby"];
        
        NSInteger savedCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"assignment-count"];
        NSInteger currentCount = assignments.count;
        
        if (savedCount < currentCount) {
            [FRSIndicatorDot addDotToTabBar:self.tabBar atIndex:3 animated:YES];
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:assignments.count forKey:@"assignment-count"];
    }];
}


#pragma mark - Icon Updating

- (void)showBell:(BOOL)bell {
    if (bell) {
        [self updateTabBarIconAtIndex:4 withImageName:@"tab-bar-bell" selectedImageName:@"tab-bar-bell-sel"];
        [FRSIndicatorDot addDotToTabBar:self.tabBar atPosition:self.view.frame.size.width - self.xOffset atIndex:4 animated:YES];
    } else {
        [self updateTabBarIconAtIndex:4 withImageName:@"tab-bar-profile" selectedImageName:@"tab-bar-profile-sel"];
        [FRSIndicatorDot removeDotInView:self.tabBar atIndex:4];
    }
}

- (void)updateTabBarIconAtIndex:(NSInteger)index withImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    UITabBarItem *item = [self.tabBar.items objectAtIndex:index];
    item.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


@end
