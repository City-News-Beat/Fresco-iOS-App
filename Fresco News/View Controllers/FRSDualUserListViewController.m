//
//  FRSDualUserListViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 12/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDualUserListViewController.h"
#import "FRSTableViewCell.h"
#import "FRSProfileViewController.h"
#import "FRSAwkwardView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"

@interface FRSDualUserListViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *galleryID;
@property (strong, nonatomic) NSMutableArray *likedUsersArray;
@property (strong, nonatomic) NSMutableArray *repostedUsersArray;

@property (strong, nonatomic) UIScrollView *horizontalScrollView;

@property (strong, nonatomic) UITableView *likesTableView;
@property (strong, nonatomic) UITableView *repostsTableView;

@property (strong, nonatomic) UIButton *likesButton;
@property (strong, nonatomic) UIButton *repostsButton;

@property (strong, nonatomic) FRSAlertView *alert;

@property BOOL didPresentError;

@end

@implementation FRSDualUserListViewController

-(instancetype)initWithGallery:(NSString *)galleryID {
    self = [super init];
    
    if (self) {
        self.galleryID = galleryID;
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureScrollers];
    [self configureNavigationBar];
    
    [self fetchData];
    
    // this in conjunction with shouldRecognizeSimultaneouslyWithGestureRecognizer enables the user
    // to swipe back to the previous view controller. UIScrollView cancels the navigation controllers popGestureRec by default
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark - UI Configuration

-(void)configureNavigationBar {
    // default config
    [super configureBackButtonAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self configureNavigationButtons];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)configureScrollers {
    
    int tabBarHeight = 49;
    int navBarHeight = 64;
    
    // horizontal scrollview config
    self.horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight))];
    self.horizontalScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height - (tabBarHeight + navBarHeight));
    self.horizontalScrollView.pagingEnabled = YES;
    self.horizontalScrollView.bounces = NO;
    self.horizontalScrollView.delegate = self;
    [self.view addSubview:self.horizontalScrollView];
    
    // likes config
    self.likesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight + navBarHeight))];
    self.likesTableView.delegate   = self;
    self.likesTableView.dataSource = self;
    [self.likesTableView setSeparatorColor:[UIColor clearColor]];
    [self.horizontalScrollView addSubview:self.likesTableView];
    self.likesTableView.backgroundColor = [UIColor clearColor];
    
    // repost config
    self.repostsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight + navBarHeight))];
    self.repostsTableView.delegate   = self;
    self.repostsTableView.dataSource = self;
    [self.horizontalScrollView addSubview:self.repostsTableView];
    [self.repostsTableView setSeparatorColor:[UIColor clearColor]];
    self.repostsTableView.backgroundColor = [UIColor clearColor];
}

-(void)configureNavigationButtons {
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;

    self.likesButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 45 - titleView.frame.size.width/5, 8, 120, 30)];
    [self.likesButton setTitle:@"LIKES" forState:UIControlStateNormal];
    [self.likesButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.likesButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.likesButton addTarget:self action:@selector(handleLikesTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.likesButton];
    
    self.repostsButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 45 + titleView.frame.size.width/8, 8, 120, 30)];
    self.repostsButton.contentMode = UIViewContentModeCenter;
    [self.repostsButton setTitle:@"REPOSTS" forState:UIControlStateNormal];
    [self.repostsButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.repostsButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.repostsButton addTarget:self action:@selector(handleRepostsTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.repostsButton];
    
    if (self.didTapRepostLabel) {
        [self handleRepostsTapped];
    } else {
        [self handleLikesTapped];
    }
}


#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.horizontalScrollView) {
        if (scrollView.contentOffset.x == 0) {
            [self handleLikesTapped];
        } else if (scrollView.contentOffset.x == self.view.frame.size.width) {
            [self handleRepostsTapped];
        }
    }
}


#pragma mark - UITableView Delegate / Datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.likesTableView) {
        return [self.likedUsersArray count];
    }
    
    if (tableView == self.repostsTableView) {
        return [self.repostedUsersArray count];
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.likesTableView) {
        FRSUser *user = [FRSUser nonSavedUserWithProperties:[self.likedUsersArray objectAtIndex:indexPath.row] context:[[FRSAPIClient sharedClient] managedObjectContext]];
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:controller animated:TRUE];
        
    } else if (tableView == self.repostsTableView) {
        FRSUser *user = [FRSUser nonSavedUserWithProperties:[self.likedUsersArray objectAtIndex:indexPath.row] context:[[FRSAPIClient sharedClient] managedObjectContext]];
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:controller animated:TRUE];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    
    FRSTableViewCell *cell = [self.likesTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (tableView == self.likesTableView && self.likedUsersArray.count > 0){

        FRSUser *user = [FRSUser nonSavedUserWithProperties:[self.likedUsersArray objectAtIndex:indexPath.row] context:[[FRSAPIClient sharedClient] managedObjectContext]];
        
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
    }
    
    if (tableView == self.repostsTableView && self.repostedUsersArray.count > 0){
        
        FRSUser *user = [FRSUser nonSavedUserWithProperties:[self.likedUsersArray objectAtIndex:indexPath.row] context:[[FRSAPIClient sharedClient] managedObjectContext]];
        
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
    }
    
    return cell;
}



#pragma mark - Navigation Bar Actions

-(void)handleLikesTapped {
    [self.likesButton   setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
    [self.repostsButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [self.horizontalScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)handleRepostsTapped {
    [self.likesButton   setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [self.repostsButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
    [self.horizontalScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}



#pragma mark - Fetch Data

-(void)fetchData {
    [self fetchLikers];
    [self fetchReposters];
}

-(void)reloadData {
    [self.likesTableView   reloadData];
    [self.repostsTableView reloadData];
}

-(void)fetchLikers {
    [self configureSpinnerInTableView:self.likesTableView];
    [[FRSAPIClient sharedClient] fetchLikesForGallery:self.galleryID completion:^(id responseObject, NSError *error) {        
        [self removeSpinnerInTableView:self.likesTableView];
        
        if (responseObject) {
            self.likedUsersArray= responseObject;
            [self reloadData];
            
            if ([self.likedUsersArray count] == 0) {
                [self configureFrogInTableView:self.likesTableView];
            }
        }
        
        if (error && !responseObject) {
            if (error.code == -1009) {
                [self configureNoConnectionBannerAlert];
            } else {
                if (!self.didPresentError) {
                    [self presentGenericError];
                    self.didPresentError = YES;
                }
            }
        }
    }];
}

-(void)fetchReposters {
    [self configureSpinnerInTableView:self.repostsTableView];
    [[FRSAPIClient sharedClient] fetchRepostsForGallery:self.galleryID completion:^(id responseObject, NSError *error) {
        [self removeSpinnerInTableView:self.repostsTableView];
        
        if (responseObject) {
            self.repostedUsersArray = responseObject;
            [self reloadData];
            
            if ([self.repostedUsersArray count] == 0) {
                [self configureFrogInTableView:self.repostsTableView];
            }
        }
        
        if (error && !responseObject) {
            if (error.code == -1009) {
                [self configureNoConnectionBannerAlert];
            } else {
                if (!self.didPresentError) {
                    [self presentGenericError];
                    self.didPresentError = YES;
                }
            }
        }
    }];
}



#pragma mark - Frog

-(void)configureFrogInTableView:(UITableView *)tableView {
    FRSAwkwardView *awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(0, tableView.frame.size.width / 2, tableView.frame.size.width, tableView.frame.size.height)];
    [tableView addSubview:awkwardView];
}

#pragma mark - Spinner

-(void)configureSpinnerInTableView:(UITableView *)tableView {
    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.frame = CGRectMake(tableView.frame.size.width/2 -10, tableView.frame.size.height/2 - 10, 20, 20);
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [tableView addSubview:spinner];
}

-(void)removeSpinnerInTableView:(UITableView *)tableView {
    for(UIView *spinner in tableView.subviews) {
        if([spinner isKindOfClass:[DGElasticPullToRefreshLoadingViewCircle class]]) {
            [spinner removeFromSuperview];
        }
    }
}


#pragma mark - FRSAlertView 

-(void)configureNoConnectionBannerAlert {
    self.alert = [[FRSAlertView alloc] initNoConnectionBannerWithBackButton:YES];
    [self.alert show];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}












@end
