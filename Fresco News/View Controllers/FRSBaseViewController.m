//
//  FRSBaseViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import "FRSNavigationController.h"

@interface FRSBaseViewController ()

@end

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //    [self configureNavigationBar];
    // Do any additional setup after loading the view.
}

//-(void)configureNavigationBar{
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
//    self.navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
//
//
//
////    [self configureBackButton];
//}

-(void)removeNavigationBarLine{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)configureBackButtonAnimated:(BOOL)animated{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    backItem.imageInsets = UIEdgeInsetsMake(2, -4.5, 0, 0);
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem animated:animated];
}

-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideTabBarAnimated:(BOOL)animated{
    if (!self.tabBarController.tabBar) return;
    
    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height;
    
    
    
    if (self.tabBarController.tabBar.frame.origin.y == yOrigin) return;
    
    self.hiddenTabBar = YES;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } completion:nil];
}

-(void)showTabBarAnimated:(BOOL)animated{
    if (!self.tabBarController.tabBar) return;
    
    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.frame.size.height;
    
    if (self.tabBarController.tabBar.frame.origin.y == yOrigin) return;
    
    self.hiddenTabBar = NO;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } completion:nil];
}

#pragma mark - Status Bar
-(void)shouldShowStatusBar:(BOOL)statusBar animated:(BOOL)animated {
    
    UIWindow *statusBarApplicationWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    
    int alpha;
    if (statusBar) {
        alpha = 1;
    } else {
        alpha = 0;
    }
    
    if (animated) {
        [UIView beginAnimations:@"fade-statusbar" context:nil];
        [UIView setAnimationDuration:0.3];
        statusBarApplicationWindow.alpha = alpha;
        [UIView commitAnimations];
    } else {
        statusBarApplicationWindow.alpha = alpha;
    }
}

@end
