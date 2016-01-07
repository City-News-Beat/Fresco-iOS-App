//
//  FRSNavigationController.m
//  Fresco
//
//  Created by Daniel Sun on 12/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSNavigationController.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

@interface FRSNavigationController ()

@end

@implementation FRSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
    
    UIImage *backImg = [UIImage imageNamed:@"back-arrow-light"];
    backImg = [backImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationBar.backIndicatorImage = backImg;
    self.navigationBar.backIndicatorTransitionMaskImage = backImg;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Do any additional setup after loading the view.
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
