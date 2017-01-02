//
//  FRSFollowersViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowersViewController.h"

#import "FRSTableViewCell.h"
#import "FRSTabbedNavigationTitleView.h"
#import "DGElasticPullToRefresh.h"
#import "FRSProfileViewController.h"
#import "FRSAwkwardView.h"

#define CELL_HEIGHT 56

@interface FRSFollowersViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FRSTabbedNavigationTitleViewDelegate>

@property (strong, nonatomic) UIButton *followersTab;
@property (strong, nonatomic) UIButton *followingTab;

@property (strong, nonatomic) NSMutableArray *followerArray;
@property (strong, nonatomic) NSMutableArray *followingArray;
@property BOOL hasLoadedOnce;

@property (strong, nonatomic) UIButton *followersTabButton;
@property (strong, nonatomic) UIButton *followingTabButton;
@property (strong, nonatomic) UIView *sudoNavBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (nonatomic, strong) UITableView *followingTable;
@property (strong, nonatomic) UIBarButtonItem *backTapButton;
@property (strong, nonatomic) FRSTableViewCell *selectedCell;
@property (strong, nonatomic) FRSAwkwardView *followingAwkward;
@property (strong, nonatomic) FRSAwkwardView *followerAwkward;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *followingSpinner;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *followerSpinner;
@property (strong, nonatomic) FRSUser *currentUser;
@property BOOL didLoadOnce;

@end

@implementation FRSFollowersViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hiddenTabBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self reloadData];

    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self addStatusBarNotification];
    [self showNavBarForScrollView:self.scrollView animated:NO];

    if (self.shouldUpdateOnReturn) {
        [self reloadData];
    } else {
        self.shouldUpdateOnReturn = NO;
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    //    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self showTabBarAnimated:YES];

    if (!self.hasLoadedOnce) {
        //[self reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeStatusBarNotification];
    self.shouldUpdateOnReturn = NO;
}
#pragma mark - Override Super

- (void)configureSpinner {
    self.followerSpinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.followerSpinner.frame = CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 44 - 10, 20, 20);
    self.followerSpinner.tintColor = [UIColor frescoOrangeColor];
    [self.followerSpinner setPullProgress:90];
    [self.followerSpinner startAnimating];
    [self.tableView addSubview:self.followerSpinner];
    self.followingSpinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.followingSpinner.frame = CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 44 - 10, 20, 20);
    self.followingSpinner.tintColor = [UIColor frescoOrangeColor];
    [self.followingSpinner setPullProgress:90];
    [self.followingSpinner startAnimating];
    [self.followingTable addSubview:self.followingSpinner];
}

- (void)configurePullToRefresh {

    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoBlueColor];

    [self.tableView dg_stopLoading];
    [self.followingTable dg_stopLoading];

    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0
                                         minOffsetToPull:80
                                     loadingContentInset:44
                                         loadingViewSize:20
                                                velocity:0
                                           actionHandler:^{
                                             [self reloadData];
                                           }
                                             loadingView:self.loadingView
                                                    yPos:0];

    [self.tableView dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}

- (void)configureNavigationBar {
    //    [super configureNavigationBar];
    [self removeNavigationBarLine];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    //    [view addGestureRecognizer:tap];

    //    int offset = 8;

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;
    //(self.navigationController.navigationBar.frame.size.width/24)
    NSLog(@"awddwadwadw %f", self.navigationItem.accessibilityFrame.size.width);
    self.followersTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 45 - titleView.frame.size.width / 6, 6, 120, 30)];
    [self.followersTabButton setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [self.followersTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.followersTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followersTabButton addTarget:self action:@selector(handleFollowersTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.followersTabButton];

    self.followingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 45 + titleView.frame.size.width / 6, 6, 120, 30)];
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

    UIButton *sudoHighlightButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 45 - titleView.frame.size.width / 6, 6, 120, 30)];
    [sudoHighlightButton setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
    [sudoHighlightButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoHighlightButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoHighlightButton];

    UIButton *sudoFollowingButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 45 + titleView.frame.size.width / 6, 6, 120, 30)];
    [sudoFollowingButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [sudoFollowingButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoFollowingButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoFollowingButton];

    self.navigationItem.title = @"EDIT YOUR PROFILE";
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [self.tableView dg_removePullToRefresh];
    [self.followingTable dg_removePullToRefresh];
    //[self release];
}

- (void)loadMoreFollowing {
    if (isAtBottomFollowing || isReloadingFollowing || self.followingArray.count == 0) {
        return;
    }

    // load more following
    FRSUser *user = [self.followingArray lastObject];
    isReloadingFollowing = TRUE;

    [[FRSAPIClient sharedClient] getFollowingForUser:_representedUser
                                                last:user
                                          completion:^(id responseObject, NSError *error) {

                                            if (error || !responseObject) {
                                                NSLog(@"LOAD MORE FOLLOWING ERROR: %@", error);
                                                return;
                                            }

                                            NSArray *users = (NSArray *)responseObject;

                                            if (users.count == 0) {
                                                isAtBottomFollowing = TRUE;
                                            }

                                            for (NSDictionary *user in users) {
                                                FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
                                                [self.followingArray addObject:newUser];
                                            }

                                            isReloadingFollowing = FALSE;
                                            [self.followingTable reloadData];
                                          }];
}

- (void)loadMoreFollowers {
    if (isAtBottomFollowers || isReloadingFollowers || self.followerArray.count == 0) {
        return;
    }

    // load more followers
    FRSUser *user = [self.followerArray lastObject];
    isReloadingFollowers = TRUE;

    [[FRSAPIClient sharedClient] getFollowersForUser:_representedUser
                                                last:user
                                          completion:^(id responseObject, NSError *error) {
                                            if (error || !responseObject) {
                                                NSLog(@"LOAD MORE FOLLOWERS ERROR: %@", error);
                                                return;
                                            }

                                            NSArray *users = (NSArray *)responseObject;

                                            if (users.count == 0) {
                                                isAtBottomFollowers = TRUE;
                                            }

                                            for (NSDictionary *user in users) {
                                                FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
                                                [self.followerArray addObject:newUser];
                                            }

                                            isReloadingFollowers = FALSE;
                                            [self.tableView reloadData];
                                          }];
}

- (void)reloadFollowing {

    if (!self.didLoadOnce) {
        [self configureSpinner];
    }

    [[FRSAPIClient sharedClient] getFollowingForUser:_representedUser
                                          completion:^(id responseObject, NSError *error) {
                                            NSLog(@"%@ %@", responseObject, error);

                                            self.didLoadOnce = YES;
                                            [self.followingSpinner removeFromSuperview];

                                            NSMutableArray *following = [[NSMutableArray alloc] init];
                                            NSArray *users = (NSArray *)responseObject;

                                            for (NSDictionary *user in users) {
                                                FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
                                                [following addObject:newUser];
                                            }

                                            self.followingArray = following;

                                            if (self.followingArray.count == 0) {
                                                [self displayAwkwardView:true followingTable:true];
                                            } else if (_hasLoadedOnce) {
                                                [self displayAwkwardView:false followingTable:true];
                                            }

                                            [self.tableView reloadData];
                                            [self.tableView dg_stopLoading];
                                            [self.followingTable reloadData];
                                            [self.followingTable dg_stopLoading];
                                            //[self.followingSpinner stopLoading];
                                            //self.followingSpinner.hidden = true;

                                            self.hasLoadedOnce = TRUE;
                                          }];
}

- (void)reloadFollowers {
    [[FRSAPIClient sharedClient] getFollowersForUser:_representedUser
                                          completion:^(id responseObject, NSError *error) {

                                            [self.followerSpinner removeFromSuperview];

                                            NSMutableArray *followers = [[NSMutableArray alloc] init];
                                            NSArray *users = (NSArray *)responseObject;

                                            for (NSDictionary *user in users) {
                                                FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
                                                [followers addObject:newUser];
                                            }

                                            self.followerArray = followers;

                                            //Awkward View
                                            if (self.followerArray.count == 0) {
                                                [self displayAwkwardView:true followingTable:false];
                                            } else if (_hasLoadedOnce) {
                                                [self displayAwkwardView:false followingTable:false];
                                            }

                                            [self.followingTable reloadData];
                                            [self.followingTable dg_stopLoading];
                                            [self.tableView reloadData];
                                            [self.tableView dg_stopLoading];
                                            //[self.followerSpinner stopLoading];
                                            //self.followerSpinner.hidden = true;
                                          }];
}

- (void)displayAwkwardView:(BOOL)show followingTable:(BOOL)following {
    if (following) {
        _followingAwkward.hidden = !show;
    } else {
        _followerAwkward.hidden = !show;
    }
}

- (void)handFollowersTabTapped {
    if (self.followersTabButton.alpha > 0.7) {
        return;
    }
    [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];

    self.followersTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;
}

- (void)handFollowingTabTapped {
    if (self.followingTabButton.alpha > 0.7) {
        return; //The button is already selected
    }

    [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];

    self.followingTabButton.alpha = 1.0;
    self.followersTabButton.alpha = 0.7;
}

#pragma mark - UI

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureTableView];
    [self configureFollowing];
    [self configureNavigationBar];
    [self configureAwkwardViews];
}

- (void)configureFollowing {
    CGRect scrollFrame = self.tableView.frame;
    scrollFrame.origin.x = scrollFrame.size.width;
    scrollFrame.origin.y = -64;

    self.followingTable = [[UITableView alloc] initWithFrame:scrollFrame];
    self.followingTable.delegate = self;
    self.followingTable.dataSource = self;
    self.followingTable.bounces = YES;
    self.followingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.followingTable setBackgroundColor:[UIColor frescoBackgroundColorDark]];
    //[self.followingTable :false];
    [self.pageScroller addSubview:self.followingTable];
}

- (void)configureTableView {
    [super configureTableView];

    CGRect newFrame = self.view.frame;
    newFrame.origin.y = self.view.frame.origin.y + 64;
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    self.tableView.frame = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 20);
    //self.tableView = [[UITableView alloc] initWithFrame:newFrame style:UITableViewStylePlain];
    [self.tableView setBackgroundColor:[UIColor frescoBackgroundColorDark]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pageScroller.delegate = self;
    [self.pageScroller addSubview:self.tableView];
    [self.view addSubview:self.pageScroller];
}

- (void)configureAwkwardViews {
    self.followerAwkward = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 64, self.view.frame.size.width, self.view.frame.size.height / 2)];
    [self.tableView addSubview:self.followerAwkward];
    self.followerAwkward.hidden = true;
    self.followerAwkward.userInteractionEnabled = false;

    self.followingAwkward = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 64, self.view.frame.size.width, self.view.frame.size.height / 2)];
    [self.followingTable addSubview:self.followingAwkward];
    self.followingAwkward.hidden = true;
    self.followerAwkward.userInteractionEnabled = false;
}

- (void)reloadData {
    /*if(!self.followerSpinner || !self.followingSpinner){
        [self configureSpinner];
    }else{
     
        [self.followerSpinner startAnimating];
        self.followerSpinner.hidden = false;
        [self.followingSpinner startAnimating];
        self.followingSpinner.hidden = false;
    }*/

    [self reloadFollowing];
    [self reloadFollowers];
}

#pragma mark - Table View Cell Actions

- (void)segueToUserProfile:(FRSUser *)user {
    FRSProfileViewController *userViewController = [[FRSProfileViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:userViewController animated:YES];
}

#pragma mark - Nav Bar Actions

- (void)handleFollowersTabTapped {
    if (self.followersTabButton.alpha > 0.7) {
        return;
    }
    [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];

    self.followersTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;
}

- (void)handleFollowingTabTapped {
    if (self.followingTabButton.alpha > 0.7) {
        return; //The button is already selected
    }

    [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];

    self.followingTabButton.alpha = 1.0;
    self.followersTabButton.alpha = 0.7;
}

- (void)tabbedNavigationTitleViewDidTapRightBarItem {
}

#pragma mark - UITableView Delegate DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tableView == tableView) {
        NSLog(@"Followers Table View");
    } else {
        NSLog(@"Following Table View");
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)self.followerArray.count);
    if (self.tableView == tableView) {
        return self.followerArray.count;
    }
    return self.followingArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 125;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    [self configurePullToRefresh]; //?

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 125)];
    //header.backgroundColor = [UIColor redColor];

    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier;

    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if (self.followingArray.count > 0 && self.followingTable == tableView) {
        FRSUser *user = [self.followingArray objectAtIndex:indexPath.row];
        self.currentUser = user;

        NSString *avatarURL;
        if (user.profileImage || ![user.profileImage isEqual:[NSNull null]]) {
            avatarURL = user.profileImage;
        }

        NSURL *avatarURLObject;
        if (avatarURL && ![avatarURL isEqual:[NSNull null]]) {
            avatarURLObject = [NSURL URLWithString:avatarURL];
        }

        NSLog(@"USERN: %@", user.username);

        [cell configureSearchUserCellWithProfilePhoto:avatarURLObject
                                             fullName:user.firstName
                                             userName:user.username
                                          isFollowing:[user.following boolValue]
                                             userDict:nil
                                                 user:user];

        if (indexPath.row >= self.followingArray.count - 3) {
            [self loadMoreFollowing];
        }
    }

    if (self.followerArray.count > 0 && self.tableView == tableView) {

        FRSUser *user = [self.followerArray objectAtIndex:indexPath.row];
        self.currentUser = user;

        NSString *avatarURL;
        if (user.profileImage || ![user.profileImage isEqual:[NSNull null]]) {
            avatarURL = user.profileImage;
        }

        NSURL *avatarURLObject;
        if (avatarURL && ![avatarURL isEqual:[NSNull null]]) {
            avatarURLObject = [NSURL URLWithString:avatarURL];
        }

        [cell configureSearchUserCellWithProfilePhoto:avatarURLObject
                                             fullName:user.firstName
                                             userName:user.username
                                          isFollowing:[user.following boolValue]
                                             userDict:nil
                                                 user:user];

        if (indexPath.row >= self.followerArray.count - 3) {
            [self loadMoreFollowers];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.tableView == tableView) {
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:((FRSUser *)self.followerArray[indexPath.row])];
        [self.navigationController pushViewController:controller animated:TRUE];
    } else {
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:((FRSUser *)self.followingArray[indexPath.row])];
        //should be followersArray
        NSLog(@"FOLLOWING: %@", ((FRSUser *)self.followingArray[indexPath.row]).following);

        [self.navigationController pushViewController:controller animated:TRUE];
    }
}

- (BOOL)isFollowingUser:(FRSUser *)user {
    for (FRSUser *userFollowed in self.followingArray) {
        if ([userFollowed.uid isEqualToString:user.uid]) {
            return true;
        }
    }
    return false;
}

#pragma mark - Scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.sudoNavBar.frame = CGRectMake(0, (scrollView.contentOffset.x / 8.5) - 88, self.view.frame.size.width, 44);

    if (scrollView == self.pageScroller) {

        self.loadingView.alpha = 1 - (scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.frame.size.width));

        //[self pausePlayers];
        if (self.pageScroller.contentOffset.x == self.view.frame.size.width) { // User is in right tab (following)
            self.followingTabButton.alpha = 1;
            self.followersTabButton.alpha = 0.7;

            [self showNavBarForScrollView:self.scrollView animated:NO];
            self.navigationItem.titleView.alpha = 1;
            [self.followingTable dg_stopLoading];

            [self.tableView dg_removePullToRefresh];
            self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            self.loadingView.tintColor = [UIColor frescoBlueColor];

            [self.followingTable dg_addPullToRefreshWithWaveMaxHeight:0
                                                      minOffsetToPull:80
                                                  loadingContentInset:44
                                                      loadingViewSize:20
                                                             velocity:0
                                                        actionHandler:^{
                                                          [self reloadData];
                                                        }
                                                          loadingView:self.loadingView
                                                                 yPos:0];

            [self.followingTable dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
            [self.followingTable dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }

        if (self.pageScroller.contentOffset.x == 0) { // User is in left tab (highlights)
            self.followingTabButton.alpha = 0.7;
            self.followersTabButton.alpha = 1;
            [self.tableView dg_stopLoading];
            [self.followingTable dg_stopLoading];
            [self.followingTable dg_removePullToRefresh];

            self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            self.loadingView.tintColor = [UIColor frescoBlueColor];

            [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0
                                                 minOffsetToPull:80
                                             loadingContentInset:44
                                                 loadingViewSize:20
                                                        velocity:0
                                                   actionHandler:^{
                                                     [self reloadData];
                                                   }
                                                     loadingView:self.loadingView
                                                            yPos:0];

            [self.tableView dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
            [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }

    } else {
        [super scrollViewDidScroll:scrollView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
