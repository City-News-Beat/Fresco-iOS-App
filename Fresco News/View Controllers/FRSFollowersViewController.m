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
#import "DGElasticPullToRefresh.h"
#import "FRSProfileViewController.h"

#define CELL_HEIGHT 56

@interface FRSFollowersViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FRSTabbedNavigationTitleViewDelegate>

@property (strong, nonatomic) UIButton *followersTab;
@property (strong, nonatomic) UIButton *followingTab;

@property (strong, nonatomic) NSArray *followerArray;
@property (strong, nonatomic) NSArray *followingArray;
@property BOOL hasLoadedOnce;

@property (strong, nonatomic) UIButton *followersTabButton;
@property (strong, nonatomic) UIButton *followingTabButton;
@property (strong, nonatomic) UIView *sudoNavBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (nonatomic, strong) UITableView *followingTable;
@property (strong, nonatomic) UIButton *backTapButton;
@property (strong, nonatomic) FRSUserTableViewCell *selectedCell;

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
    [self reloadFollowing];
    [self reloadFollowers];
    [self configureFollowing];
    
    self.scrollView.delegate = self;

    return;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addStatusBarNotification];
    [self showNavBarForScrollView:self.scrollView animated:NO];
    
    if(self.selectedCell){
        [self.selectedCell setSelected:false];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    //[FRSUser reloadUser];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTabBarAnimated:YES];
    
    if (!self.hasLoadedOnce) {
        [self reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self removeStatusBarNotification];
}
#pragma mark - Override Super

-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

-(void)configurePullToRefresh {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
        [weakSelf reloadData];
    } loadingView:self.loadingView];
    
    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}

-(void)configureNavigationBar{
//    [super configureNavigationBar];
    [self removeNavigationBarLine];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [container addSubview:backButton];
    
    backButton.tintColor = [UIColor whiteColor];
    //    backButton.backgroundColor = [UIColor redColor];
    backButton.frame = CGRectMake(-15, -12, 48, 48);
    backButton.imageView.frame = CGRectMake(-12, 0, 48, 48); //this doesnt change anything
    //    backButton.imageView.backgroundColor = [UIColor greenColor];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:container];
    
    
    self.backTapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [self.backTapButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    //    self.backTapButton.backgroundColor = [UIColor blueColor];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backTapButton];
    
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    //    [view addGestureRecognizer:tap];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
//    int offset = 8;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;
    //(self.navigationController.navigationBar.frame.size.width/24)
    NSLog(@"awddwadwadw %f",self.navigationItem.accessibilityFrame.size.width);
    self.followersTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 45 - titleView.frame.size.width/6, 6, 120, 30)];
    [self.followersTabButton setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [self.followersTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.followersTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followersTabButton addTarget:self action:@selector(handleFollowersTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.followersTabButton];
    
    self.followingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 45 + titleView.frame.size.width/6, 6, 120, 30)];
    self.followingTabButton.alpha = 0.7;
    self.followingTabButton.contentMode = UIViewContentModeCenter;
    [self.followingTabButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.followingTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.followingTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followingTabButton addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.followingTabButton];
    
    /* Configure sudo nav bar when scrolling for scrolling between tabs and nav bar is hidden */
    self.sudoNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, -88, self.view.frame.size.width, 44)];
    self.sudoNavBar.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:self.sudoNavBar];
    
    UIButton *sudoHighlightButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 45 - titleView.frame.size.width/6, 6, 120, 30)];
    [sudoHighlightButton setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [sudoHighlightButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoHighlightButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoHighlightButton];
    
    UIButton *sudoFollowingButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 45 + titleView.frame.size.width/6, 6, 120, 30)];
    [sudoFollowingButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [sudoFollowingButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoFollowingButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoFollowingButton];
    
    self.navigationItem.title = @"EDIT YOUR PROFILE";
}

-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
    [self.backTapButton removeFromSuperview];
}

-(void)dealloc{
    [self.tableView dg_removePullToRefresh];
    [self.followingTable dg_removePullToRefresh];
//[self release];
}

-(void)reloadFollowing{
    [self configurePullToRefresh];

    [[FRSAPIClient sharedClient] getFollowingForUser:_representedUser completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
        NSDictionary *userInfo = (NSDictionary *)responseObject;
        
        NSMutableArray *following = [[NSMutableArray alloc] init];
        
        for (NSDictionary *user in responseObject[@"users"]) {
            FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
            [following addObject:newUser];
        }
        
        self.followingArray = following;
        
        [self.followingTable reloadData];
        [self.followingTable dg_stopLoading];
        if(self.loadingView){
            [self.loadingView stopLoading];
            [self.loadingView removeFromSuperview];
        }
        self.hasLoadedOnce = TRUE;
    }];
}

-(void)reloadFollowers{
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
        [self.tableView dg_stopLoading];
    }];
}

-(void)handFollowersTabTapped{
    if (self.followersTabButton.alpha > 0.7) {
        return;
    }
    [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];
    
    self.followersTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;}

-(void)handFollowingTabTapped{
    if (self.followingTabButton.alpha > 0.7) {
        return; //The button is already selected
    }
    
    [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
    
    self.followingTabButton.alpha = 1.0;
    self.followersTabButton.alpha = 0.7;
}

#pragma mark - UI

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureTableView];
    [self configureNavigationBar];
}

-(void)configureFollowing {
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = self.view.frame.origin.y + 64;
    newFrame.origin.x = self.view.frame.size.width;
    
    self.followingTable = [[UITableView alloc] initWithFrame:newFrame];
    self.followingTable.delegate = self;
    self.followingTable.dataSource = self;
    self.followingTable.bounces = YES;
    self.followingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.pageScroller addSubview:self.followingTable];
}

-(void)configureTableView{
    [super configureTableView];
    
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = self.view.frame.origin.y + 64;
    self.tableView = [[UITableView alloc] initWithFrame:newFrame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pageScroller.delegate = self;
    [self.pageScroller addSubview:self.tableView];
    [self.view addSubview:self.pageScroller];
}

-(void)reloadData {
    [self reloadFollowing];
    [self reloadFollowers];
}

#pragma mark - Table View Cell Actions

-(void)segueToUserProfile:(FRSUser *)user {
    FRSProfileViewController *userViewController = [[FRSProfileViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:userViewController animated:YES];
}

#pragma mark - Nav Bar Actions

-(void)handleFollowersTabTapped{
    if (self.followersTabButton.alpha > 0.7) {
        return;
    }
    [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];
    
    self.followersTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;
}


-(void)handleFollowingTabTapped{
    if (self.followingTabButton.alpha > 0.7) {
        return; //The button is already selected
    }
    
    [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
    
    self.followingTabButton.alpha = 1.0;
    self.followersTabButton.alpha = 0.7;
}

-(void)tabbedNavigationTitleViewDidTapRightBarItem{
    
}

#pragma mark - UITableView Delegate DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.tableView == tableView){
        NSLog(@"Followers Table View");
    }else{
        NSLog(@"Following Table View");
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%lu",(unsigned long)self.followerArray.count);
    if(self.tableView == tableView){
        return self.followerArray.count;
    }
    return self.followingArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user-cell"];
    if (!cell){
        cell = [[FRSUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user-cell"];
    }
    CGRect newFrame = cell.frame;
    newFrame.size.width = self.view.frame.size.width;
    [cell setFrame:newFrame];
    if(self.followingArray.count > 0 && self.followingTable == tableView){
        [cell clearCell];
        FRSUser *user = [self.followingArray objectAtIndex:indexPath.row];
        NSLog(@"Following Cell #%i %@",(int)indexPath.row, user.uid);
        cell.cellHeight = CELL_HEIGHT;
        [cell configureCellWithUser:user isFollowing:[self isFollowingUser:user]];
    }
    if(self.followerArray.count > 0 && self.tableView == tableView){
        [cell clearCell];
        FRSUser *user = [self.followerArray objectAtIndex:indexPath.row];
        NSLog(@"Follower Cell #%i %@",(int)indexPath.row, user.uid);
        cell.cellHeight = CELL_HEIGHT;
        [cell configureCellWithUser:user isFollowing:[self isFollowingUser:user]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Check if horizontal scrollView to avoid issues with potentially conflicting scrollViews
    FRSUserTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self segueToUserProfile:cell.user];
    self.selectedCell = cell;
}

-(BOOL)isFollowingUser:(FRSUser *) user{
    for(FRSUser *userFollowed in self.followingArray){
        if([userFollowed.uid isEqualToString:user.uid]){
            return true;
        }
    }
    return false;
}

#pragma mark - Scrolling

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.sudoNavBar.frame = CGRectMake(0, (scrollView.contentOffset.x/8.5)-88, self.view.frame.size.width, 44);

    if (scrollView == self.pageScroller) {
        
        self.loadingView.alpha = 1-(scrollView.contentOffset.x/(scrollView.contentSize.width - scrollView.frame.size.width));
        
        //[self pausePlayers];
        if (self.pageScroller.contentOffset.x == self.view.frame.size.width) { // User is in right tab (following)
            self.followingTabButton.alpha = 1;
            self.followersTabButton.alpha = 0.7;
            
            [self showNavBarForScrollView:self.scrollView animated:NO];
            self.navigationItem.titleView.alpha = 1;
            [self.followingTable dg_stopLoading];
            
            [self.tableView dg_removePullToRefresh];
            self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            self.loadingView.tintColor = [UIColor whiteColor];
            
            __weak typeof(self) weakSelf = self;
            [self.followingTable dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
                [weakSelf reloadData];
            } loadingView:self.loadingView];
            
            [self.followingTable dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
            [self.followingTable dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }
        
        if (self.pageScroller.contentOffset.x == 0) { // User is in left tab (highlights)
            self.followingTabButton.alpha = 0.7;
            self.followersTabButton.alpha = 1;
            [self.tableView dg_stopLoading];
            [self.followingTable dg_stopLoading];
            
            [self.followingTable dg_removePullToRefresh];
            
            self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            self.loadingView.tintColor = [UIColor whiteColor];
            
            __weak typeof(self) weakSelf = self;
            [self.tableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
                [weakSelf reloadData];
            } loadingView:self.loadingView];
            
            [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
            [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }
        
    }
    else {
        [super scrollViewDidScroll:scrollView];
    }
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
