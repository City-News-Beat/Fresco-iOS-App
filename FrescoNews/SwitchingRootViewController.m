//
//  SwitchingRootViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "SwitchingRootViewController.h"

@interface SwitchingRootViewController () <UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) UIViewController *viewController;
@end

@implementation SwitchingRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - View Controller swapping

- (void)setRootViewControllerToTabBar
{
    UITabBarController *tbc = (UITabBarController *)[self setRootViewControllerWithIdentifier:@"tabBarController" underNavigationController:NO];
    [self setupTabBarAppearances:tbc];
}

- (void)setRootViewControllerToFirstRun
{
    [self setRootViewControllerWithIdentifier:@"firstRunViewController" underNavigationController:YES];
}

- (UIViewController *)setRootViewControllerWithIdentifier:(NSString *)identifier underNavigationController:(BOOL)underNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    UIViewController *viewController;
    if (underNavigationController) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.navigationController.navigationBar.hidden = YES;
    }
    else
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    // swap the view controllers
    UIViewController *source = self.viewController;
    UIViewController *destination = viewController;
    UIViewController *container = self;
    
    [container addChildViewController:destination];
    
    // we'll always be replacing our whole view
    destination.view.frame = self.view.bounds;
    
    if (source) {
        [source willMoveToParentViewController:nil];
        [container transitionFromViewController:source
                               toViewController:destination
                                       duration:0.5
                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                     animations:^{
                                     }
                                     completion:^(BOOL finished) {
                                         [source removeFromParentViewController];
                                         [destination didMoveToParentViewController:container];
                                     }];
    }
    else {
        [self.view addSubview:destination.view];
        [destination didMoveToParentViewController:container];
    }
    
    // store the new view controller
    self.viewController = viewController;
    
    return viewController;
}

- (void)setupTabBarAppearances:(UITabBarController *)tabBarController
{
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:[VariableStore sharedInstance].colorBrandDark]];
    
    NSArray *highlightedTabNames = @[@"tab-home-highlighted",
                                     @"tab-stories-highlighted",
                                     @"tab-camera-highlighted",
                                     @"tab-assignments-highlighted",
                                     @"tab-profile-highlighted"];
    
    
    tabBarController.delegate = self;
    
    UITabBar *tabBar = tabBarController.tabBar;
    
    int i = 0;
    
    for (UITabBarItem *item in tabBar.items) {
        if (i == 2) {
            item.image = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.selectedImage = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.imageInsets = UIEdgeInsetsMake(5.5, 0, -6, 0);
        }
        else {
            item.selectedImage = [UIImage imageNamed:highlightedTabNames[i]];
        }
        ++i;
    }
}

@end