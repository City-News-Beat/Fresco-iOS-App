//
//  FRSBaseViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@interface FRSBaseViewController ()

@end

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    // Do any additional setup after loading the view.
}

-(void)configureNavigationBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
    self.navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    [self configureBackButton];
}

-(void)removeNavigationBarLine{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)configureBackButtonAnimated:(BOOL)animated{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    [self.navigationItem setLeftBarButtonItem:backItem animated:animated];
}

-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideTabBarAnimated:(BOOL)animated{
    if (!self.tabBarController.tabBar) return;

    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height;
    
    if (self.tabBarController.tabBar.frame.origin.y == yOrigin) return;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } completion:nil];
}

-(void)showTabBarAnimated:(BOOL)animated{
    if (!self.tabBarController.tabBar) return;
    
    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.frame.size.height;
    
    if (self.tabBarController.tabBar.frame.origin.y == yOrigin) return;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
