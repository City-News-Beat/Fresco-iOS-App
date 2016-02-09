//
//  FRSFollowersViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowersViewController.h"

#import "FRSUserTableViewCell.h"

#define CELL_HEIGHT 56

@interface FRSFollowersViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIButton *followersTab;
@property (strong, nonatomic) UIButton *followingTab;

@property (strong, nonatomic) NSArray *dataSourceArray;

@end

@implementation FRSFollowersViewController

-(instancetype)init{
    self = [super init];
    if (self){
        self.hiddenTabBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    // Do any additional setup after loading the view.
}

#pragma mark - Override Super

-(void)configureNavigationBar{
    [super configureNavigationBar];
    [self configureBackButtonAnimated:NO];
    [self removeNavigationBarLine];
    
    self.followersTab = [[UIButton alloc] init];
    [self.followersTab setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [self.followersTab setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.followersTab setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
    [self.followersTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followersTab sizeToFit];
    [self.followersTab addTarget:self action:@selector(handleFollowersTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.followersTab setFrame:CGRectMake(0, 0, self.followersTab.frame.size.width, 44)];
    self.followersTab.selected = YES;
    
    self.followingTab = [[UIButton alloc] init];
    [self.followingTab setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.followingTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followingTab setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.followingTab setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
    [self.followingTab sizeToFit];
    [self.followingTab addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger xOrigin = (self.view.frame.size.width - (36 * 2) - self.followingTab.frame.size.width - self.followersTab.frame.size.width)/3;
    
    [self.followingTab setFrame:CGRectMake(self.followersTab.frame.size.width + xOrigin, 0, self.followingTab.frame.size.width, 44)];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(36 + xOrigin, 20, self.followingTab.frame.size.width + self.followersTab.frame.size.width + xOrigin, 44)];
    titleView.backgroundColor = [UIColor blueColor];
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
    [self configureTableView];
}

-(void)configureTableView{
    [super configureTableView];
    self.tableView.delegate =self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

#pragma mark - Tabbing

-(void)handleFollowersTabTapped{
    if (!self.followersTab.selected){
        [self.followersTab setSelected:YES];
        [self.followingTab setSelected:NO];
    }
}

-(void)handleFollowingTabTapped{
    if (!self.followingTab.selected){
        [self.followingTab setSelected:YES];
        [self.followersTab setSelected:NO];
    }
}


#pragma mark - UITableView Delegate DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return self.dataSourceArray.count;
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user-cell"];
    if (!cell){
        cell = [[FRSUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user-cell"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSUserTableViewCell *userCell = (FRSUserTableViewCell *)cell;
    [userCell clearCell];
    [userCell configureCellWithUser:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Scrolling

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentSize.height < self.tableView.frame.size.height) return;
    [super scrollViewDidScroll:scrollView];
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
