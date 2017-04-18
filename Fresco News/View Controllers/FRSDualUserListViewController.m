//
//  FRSDualUserListViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 12/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDualUserListViewController.h"
#import "FRSProfileViewController.h"
#import "FRSAwkwardView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSGalleryManager.h"
#import "FRSConnectivityAlertView.h"
#import "FRSUserTableViewCell.h"
#import "FRSFollowManager.h"

@interface FRSDualUserListViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIScrollView *horizontalScrollView;

@property BOOL isLoadingLeft;
@property BOOL isLoadingRight;
@property BOOL hasReachedEndOfLeft;
@property BOOL hasReachedEndOfRight;

@property (strong, nonatomic) NSMutableArray *leftUsersArray;
@property (strong, nonatomic) NSMutableArray *rightUsersArray;

@property (strong, nonatomic) UITableView *leftTableView;
@property (strong, nonatomic) UITableView *rightTableView;

@property (strong, nonatomic) UIButton *leftNavigationBarButton;
@property (strong, nonatomic) UIButton *rightNavigationBarButton;

@property BOOL didPresentError;

@end

@implementation FRSDualUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureScrollers];
    [self configureDataSource];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}

#pragma mark - UI Configuration

- (void)configureNavigationBar {
    [super configureBackButtonAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [self configureNavigationButtons];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    // this in conjunction with shouldRecognizeSimultaneouslyWithGestureRecognizer enables the user
    // to swipe back to the previous view controller. UIScrollView cancels the navigation controllers popGestureRec by default
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)configureNavigationButtons {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;

    self.leftNavigationBarButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 45 - titleView.frame.size.width / 5, 8, 120, 30)];
    [self.leftNavigationBarButton setTitle:self.leftTitle forState:UIControlStateNormal];
    [self.leftNavigationBarButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.leftNavigationBarButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.leftNavigationBarButton addTarget:self action:@selector(handleLeftTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.leftNavigationBarButton];

    self.rightNavigationBarButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 45 + titleView.frame.size.width / 8, 8, 120, 30)];
    self.rightNavigationBarButton.contentMode = UIViewContentModeCenter;
    [self.rightNavigationBarButton setTitle:self.rightTitle forState:UIControlStateNormal];
    [self.rightNavigationBarButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.rightNavigationBarButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.rightNavigationBarButton addTarget:self action:@selector(handleRightTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.rightNavigationBarButton];
}

- (void)configureScrollers {
    int tabBarHeight = 49;
    int navBarHeight = 64;
    
    self.horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight))];
    self.horizontalScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height - (tabBarHeight + navBarHeight));
    self.horizontalScrollView.pagingEnabled = YES;
    self.horizontalScrollView.bounces = NO;
    self.horizontalScrollView.delegate = self;
    [self.view addSubview:self.horizontalScrollView];
    
    self.leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight + navBarHeight))];
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    [self.leftTableView setSeparatorColor:[UIColor clearColor]];
    [self.horizontalScrollView addSubview:self.leftTableView];
    self.leftTableView.backgroundColor = [UIColor clearColor];
    
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight + navBarHeight))];
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    [self.horizontalScrollView addSubview:self.rightTableView];
    [self.rightTableView setSeparatorColor:[UIColor clearColor]];
    self.rightTableView.backgroundColor = [UIColor clearColor];
    
    [self.leftTableView registerNib:[UINib nibWithNibName:@"FRSUserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:userCellIdentifier];
    [self.rightTableView registerNib:[UINib nibWithNibName:@"FRSUserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:userCellIdentifier];
}

#pragma mark - Data Source
- (void)configureDataSource {
    
    // TODO: The way we handle the UI updating can be pulled out into one method.
    
    [self fetchLeftDataSourceWithCompletion:^(id responseObject, NSError *error) {

        [self removeSpinnerInTableView:self.leftTableView];
        
        if (responseObject) {
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (NSDictionary *user in responseObject) {
                FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSGalleryManager sharedInstance] managedObjectContext]];
                [users addObject:newUser];
            }
            
            self.leftUsersArray = users;
            [self.leftTableView reloadData];
            
            if ([self.leftUsersArray count] == 0) {
                [self configureFrogInTableView:self.leftTableView];
            }
        } else if (error && !responseObject) {
            if (error.code == -1009) {
                [self configureNoConnectionBannerAlert];
            } else {
                if (!self.didPresentError) {
                    [self presentGenericError];
                    self.didPresentError = YES;
                }
            }
        }
        
        self.isLoadingLeft = NO;
    }];
    
    [self fetchRightDataSourceWithCompletion:^(id responseObject, NSError *error) {
        
        [self removeSpinnerInTableView:self.rightTableView];
        
        if (responseObject) {
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (NSDictionary *user in responseObject) {
                FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSGalleryManager sharedInstance] managedObjectContext]];
                [users addObject:newUser];
            }
            
            self.rightUsersArray = users;
            [self.rightTableView reloadData];
            
            if ([self.rightUsersArray count] == 0) {
                [self configureFrogInTableView:self.rightTableView];
            }
        } else if (error && !responseObject) {
            if (error.code == -1009) {
                [self configureNoConnectionBannerAlert];
            } else {
                if (!self.didPresentError) {
                    [self presentGenericError];
                    self.didPresentError = YES;
                }
            }
        }
        
        self.isLoadingRight = NO;
    }];
}

- (void)fetchLeftDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    completion(@[], nil);
}

- (void)fetchRightDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    completion(@[], nil);
}

- (void)loadMoreLeftUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    completion(@[], nil);
}

- (void)loadMoreRightUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    completion(@[], nil);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.horizontalScrollView) {
        if (scrollView.contentOffset.x == 0) {
            [self handleLeftTabTapped];
        } else if (scrollView.contentOffset.x == self.view.frame.size.width) {
            [self handleRightTabTapped];
        }
    }

    if (scrollView == self.leftTableView || scrollView == self.rightTableView) {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentYoffset = scrollView.contentOffset.y;
        CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        
        // TODO: The way we handle the UI updating can be pulled out into one method.

        if (distanceFromBottom < height) {
            if (scrollView == self.leftTableView) {
                
                if (self.isLoadingLeft || [self.leftUsersArray count] == 0 || self.hasReachedEndOfLeft) {
                    return;
                }
                
                self.isLoadingLeft = YES;
                
                NSString *lastUserID = @"";
                if ([self.leftUsersArray lastObject]) {
                    lastUserID = [(FRSUser *)[self.leftUsersArray lastObject] uid];
                }
                
                [self loadMoreLeftUsersFromLast:lastUserID withCompletion:^(id responseObject, NSError *error) {
                    
                    for (NSDictionary *user in responseObject) {
                        FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSGalleryManager sharedInstance] managedObjectContext]];
                        [self.leftUsersArray addObject:newUser];
                    }
                    
                    if ([responseObject count] == 0) {
                        self.hasReachedEndOfLeft = YES;
                    }
                    
                    [self.leftTableView reloadData];
                    
                    self.isLoadingLeft = NO;
                }];
                
            } else if (scrollView == self.rightTableView) {
            
                if (self.isLoadingRight || [self.rightUsersArray count] == 0 || self.hasReachedEndOfRight) {
                    return;
                }
                
                self.isLoadingRight = YES;
                
                NSString *lastUserID = @"";
                if ([self.rightUsersArray lastObject]) {
                    lastUserID = [(FRSUser *)[self.rightUsersArray lastObject] uid];
                }
                
                [self loadMoreRightUsersFromLast:lastUserID withCompletion:^(id responseObject, NSError *error) {
                    for (NSDictionary *user in responseObject) {
                        FRSUser *newUser = [FRSUser nonSavedUserWithProperties:user context:[[FRSGalleryManager sharedInstance] managedObjectContext]];
                        [self.rightUsersArray addObject:newUser];
                    }
                    
                    if ([responseObject count] == 0) {
                        self.hasReachedEndOfRight = YES;
                    }
                    
                    [self.rightTableView reloadData];
                    
                    self.isLoadingRight = NO;
                }];
            }
        }
    }
}

#pragma mark - UITableView Delegate / Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) {
        return [self.leftUsersArray count];
    }

    if (tableView == self.rightTableView) {
        return [self.rightUsersArray count];
    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        FRSUser *user = [self.leftUsersArray objectAtIndex:indexPath.row];
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:controller animated:TRUE];

    } else if (tableView == self.rightTableView) {
        FRSUser *user = [self.rightUsersArray objectAtIndex:indexPath.row];
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:controller animated:TRUE];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // We need to create a cell for both the left and right tableviews in order to avoid any UI flasing on reload.
    if (tableView == self.leftTableView && self.leftUsersArray.count > 0) {
        FRSUserTableViewCell *leftCell = [self.leftTableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        FRSUser *user = [self.leftUsersArray objectAtIndex:indexPath.row];
        [leftCell loadDataWithUser:user];
        return leftCell;
    } else if (tableView == self.rightTableView && self.rightUsersArray.count > 0) {
        FRSUserTableViewCell *rightCell = [self.rightTableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        FRSUser *user = [self.rightUsersArray objectAtIndex:indexPath.row];
        [rightCell loadDataWithUser:user];
        return rightCell;
    }

    // This shouldn't ever get called.
    FRSUserTableViewCell *cell = [self.rightTableView dequeueReusableCellWithIdentifier:userCellIdentifier];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return userCellHeight;
}


#pragma mark - Navigation Bar Actions

- (void)handleLeftTabTapped {
    [self.leftNavigationBarButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
    [self.rightNavigationBarButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [self.horizontalScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)handleRightTabTapped {
    [self.leftNavigationBarButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [self.rightNavigationBarButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
    [self.horizontalScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}


#pragma mark - Frog

- (void)configureFrogInTableView:(UITableView *)tableView {
    FRSAwkwardView *awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(0, tableView.frame.size.width / 2, tableView.frame.size.width, tableView.frame.size.height)];
    [tableView addSubview:awkwardView];
}

#pragma mark - Spinner

- (void)configureSpinnerInTableView:(UITableView *)tableView {
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.frame = CGRectMake(tableView.frame.size.width / 2 - 10, tableView.frame.size.height / 2 - 10, 20, 20);
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [tableView addSubview:spinner];
}

- (void)removeSpinnerInTableView:(UITableView *)tableView {
    for (UIView *spinner in tableView.subviews) {
        if ([spinner isKindOfClass:[DGElasticPullToRefreshLoadingViewCircle class]]) {
            [spinner removeFromSuperview];
        }
    }
}

#pragma mark - FRSAlertView

- (void)configureNoConnectionBannerAlert {
    FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionBannerWithBackButton:YES];
    [alert show];
}

@end
