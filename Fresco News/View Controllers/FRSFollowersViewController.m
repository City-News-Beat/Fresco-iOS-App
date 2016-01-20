//
//  FRSFollowersViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowersViewController.h"

@interface FRSFollowersViewController ()

@property (strong, nonatomic) UIButton *followersTab;
@property (strong, nonatomic) UIButton *followingTab;

@end

@implementation FRSFollowersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    // Do any additional setup after loading the view.
}

#pragma mark - Override Super

-(void)configureNavigationBar{
    [super configureNavigationBar];
    [super configureBackButtonAnimated:NO];

    
    self.followersTab = [[UIButton alloc] init];
    self.followersTab.backgroundColor = [UIColor blueColor];
    [self.followersTab setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [self.followersTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followersTab sizeToFit];
    [self.followersTab setFrame:CGRectMake(0, 0, self.followersTab.frame.size.width, 44)];
    
    self.followingTab = [[UIButton alloc] init];
    self.followingTab.backgroundColor = [UIColor redColor];
    [self.followingTab setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.followingTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followingTab sizeToFit];
    
    NSInteger xOrigin = (self.view.frame.size.width - (36 * 2) - self.followingTab.frame.size.width - self.followersTab.frame.size.width)/3;
    
    [self.followingTab setFrame:CGRectMake(self.followersTab.frame.size.width + xOrigin, 0, self.followersTab.frame.size.width, 44)];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(36 + xOrigin, 20, self.followingTab.frame.size.width + self.followersTab.frame.size.width + xOrigin, 44)];
    titleView.backgroundColor = [UIColor brownColor];
    self.navigationItem.titleView = titleView;
    
    [titleView addSubview:self.followersTab];
    [titleView addSubview:self.followingTab];
    
}

-(void)popViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI

-(void)configureUI{
    self.view.backgroundColor = [UIColor whiteColor];
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
