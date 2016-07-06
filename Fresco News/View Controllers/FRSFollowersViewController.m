//
//  FRSFollowersViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowersViewController.h"

#import "FRSUserTableViewCell.h"
#import "FRSTabbedNavigationTitleView.h"

#define CELL_HEIGHT 56

@interface FRSFollowersViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FRSTabbedNavigationTitleViewDelegate>

@property (strong, nonatomic) UIButton *followersTab;
@property (strong, nonatomic) UIButton *followingTab;

@property (strong, nonatomic) NSArray *followerArray;
@property (strong, nonatomic) NSArray *followingArray;

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
    
    [[FRSAPIClient sharedClient] getFollowersForUser:_representedUser completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
        NSDictionary *userInfo = (NSDictionary *)responseObject;
        
        NSMutableArray *followers = [[NSMutableArray alloc] init];
        
        for (NSDictionary *user in responseObject[@"users"]) {
            FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
            [followers addObject:newUser];
        }
        
        self.followerArray = followers;
        
        [self.tableView reloadData];
    }];
    
    return;
    [[FRSAPIClient sharedClient] getFollowingForUser:_representedUser completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
        NSDictionary *userInfo = (NSDictionary *)responseObject;
        
        NSMutableArray *following = [[NSMutableArray alloc] init];
        
        for (NSDictionary *user in responseObject[@"users"]) {
            FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
            [following addObject:newUser];
        }
        
        self.followingArray = following;
        
        [self.tableView reloadData];
    }];
    // Do any additional setup after loading the view.
}
#pragma mark - Override Super

-(void)configureNavigationBar{
//    [super configureNavigationBar];
    [self configureBackButtonAnimated:NO];
    [self removeNavigationBarLine];
    
    //    self.followersTab = [[UIButton alloc] init];
//    [self.followersTab setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
//    [self.followersTab setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [self.followersTab setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
//    [self.followersTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
//    [self.followersTab sizeToFit];
//    [self.followersTab addTarget:self action:@selector(handleFollowersTabTapped) forControlEvents:UIControlEventTouchUpInside];
//    [self.followersTab setFrame:CGRectMake(0, 0, self.followersTab.frame.size.width, 44)];
//    self.followersTab.selected = YES;

//    
//    self.followingTab = [[UIButton alloc] init];
//    [self.followingTab setTitle:@"FOLLOWING" forState:UIControlStateNormal];
//    [self.followingTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
//    [self.followingTab setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [self.followingTab setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
//    [self.followingTab sizeToFit];
//    [self.followingTab addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    
//    NSInteger xOrigin = (self.view.frame.size.width - (36 * 2) - self.followingTab.frame.size.width - self.followersTab.frame.size.width)/3;
//    
//    [self.followingTab setFrame:CGRectMake(self.followersTab.frame.size.width + xOrigin, 0, self.followingTab.frame.size.width, 44)];
//    
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(36 + xOrigin, 20, self.followingTab.frame.size.width + self.followersTab.frame.size.width + xOrigin, 44)];
//    titleView.backgroundColor = [UIColor blueColor];
    self.navigationItem.titleView = [[FRSTabbedNavigationTitleView alloc] initWithTabTitles:@[@"FOLLOWERS", @"FOLLOWING"] delegate:self hasBackButton:YES];
}

-(void)popViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureTableView];
}

-(void)configureTableView{
    [super configureTableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setFrame:self.view.frame];
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

-(void)tabbedNavigationTitleViewDidTapRightBarItem{
    
}

#pragma mark - UITableView Delegate DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%lu",(unsigned long)self.followerArray.count);
    return self.followerArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user-cell"];
    if (!cell){
        cell = [[FRSUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user-cell"];
    }
    if(self.followerArray.count > 0){
        [cell clearCell];
        FRSUser *user = [self.followerArray objectAtIndex:indexPath.row];
        NSLog(@"Cell #%i %@",(int)indexPath.row, user.uid);
        cell.cellHeight = CELL_HEIGHT;
        [cell configureCellWithUser:user];
    }
    return cell;
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
