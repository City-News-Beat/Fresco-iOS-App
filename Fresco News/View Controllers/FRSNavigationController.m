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
#import "UIView+Helpers.h"

@interface FRSNavigationController ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *firstTab;
@property (strong, nonatomic) UIButton *secondTab;

@property (strong, nonatomic) UIButton *leftBarItem;
@property (strong, nonatomic) UIButton *rightBarItem;

@property (strong, nonatomic) UIButton *extraBarItem;

@end

@implementation FRSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.titleView.backgroundColor = [UIColor frescoOrangeColor];
    [self.containerView addSubview:self.titleView];
    
    
//    self.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Do any additional setup after loading the view.
}

-(void)configureFRSNavigationBarWithTitle:(NSString *)title{
    
    if (!self.titleLabel){
        self.titleLabel = [[UILabel alloc] init];
        [self.titleView addSubview:self.titleLabel];
    }
    
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont notaBoldWithSize:17];
    [self.titleLabel sizeToFit];
    
    [self.titleLabel centerHorizontallyInView:self.titleView];
    [self.titleLabel setOriginWithPoint:CGPointMake(self.titleLabel.frame.origin.x, 15)];
    
    self.navigationBar.topItem.titleView = self.containerView;
    
}

-(void)configureFRSNavigationBarWithTabs:(NSArray *)tabs{
    
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
