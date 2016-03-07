//
//  FRSTabBarController.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
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


@interface FRSTabBarController () <UITabBarControllerDelegate>

@property (strong, nonatomic) UIView *cameraBackgroundView;

@end

@implementation FRSTabBarController


-(void)returnToGalleryPost {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    [self configureAppearance];
    [self configureViewControllers];
    
    [self configureTabBarItems];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
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
}

-(void)configureViewControllers{
    UIViewController *vc = [[FRSNavigationController alloc] initWithRootViewController:[[FRSHomeViewController alloc] init]];

    UIViewController *vc1 = [[FRSNavigationController alloc] initWithRootViewController:[[FRSStoriesViewController alloc] init]];

    UIViewController *vc2 = [UIViewController new];
    vc2.view.backgroundColor = [UIColor blackColor];
    
    UIViewController *vc3 = [[FRSNavigationController alloc] initWithRootViewController:[[FRSAssignmentsViewController alloc] init]];
    UIViewController *vc4 = [[FRSNavigationController alloc] initWithRootViewController:[[FRSProfileViewController alloc] init]];
    
    self.viewControllers = @[vc, vc1, vc2, vc3, vc4];
}

-(void)configureIrisItem{
    
    CGFloat origin = self.view.frame.size.width * 2/5;
    CGFloat width = self.view.frame.size.width/5;
    
    self.cameraBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(origin, 0, width, 50)];
    self.cameraBackgroundView.backgroundColor = [UIColor frescoOrangeColor];
    [self.tabBar insertSubview:self.cameraBackgroundView atIndex:0];
    
}

-(void)setIrisItemColor:(UIColor *)color{
    self.cameraBackgroundView.backgroundColor = color;
}

#pragma mark Delegate

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    if ([self.tabBar.items indexOfObject:item] == 2) {
        FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
        [self presentViewController:cam animated:YES completion:^{
            [self setSelectedIndex:self.lastActiveIndex];
        }];
    }
}


//
//-(void)handleHomeTabPressed{
//    
//}
//
//-(void)handleStoryTabPressed{
//    self.lastActiveIndex = 1;
//}
//
//-(void)handleCameraTabPressed{
////    FRSCameraViewController *camVC = [[FRSCameraViewController alloc] init];
////    [self presentViewController:camVC animated:YES completion:nil];
//}
//
//-(void)handleAssignmentTabPressed{
//    self.lastActiveIndex = 3;
//}
//
//-(void)handleProfileTabPressed{
//    self.lastActiveIndex = 4;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    NSLog(@"viewController = %@", viewController);
//}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
//    UD_PREVIOUSLY_SELECTED_TAB = tabBarController.selectedIndex;
    
    UIViewController *selectedVC = viewController;
    if ([viewController isKindOfClass:[FRSNavigationController class]]){
        FRSNavigationController *nav = (FRSNavigationController *)viewController;
        selectedVC = [nav.viewControllers firstObject];
    }
    
    self.lastActiveIndex = tabBarController.selectedIndex;
    
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    
    switch (index) {
        case 0:
            break;
        case 1:
            
            break;
        case 2:
            return NO;
        case 3:
            if (self.lastActiveIndex == 3){
                
                if (![selectedVC isKindOfClass:[FRSAssignmentsViewController class]]) break;
                
                FRSAssignmentsViewController *assignVC = (FRSAssignmentsViewController *)selectedVC;
                [assignVC setInitialMapRegion];
            }
            break;
        case 4:
            break;
            
        default:
            break;
    }
    
    return YES;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
