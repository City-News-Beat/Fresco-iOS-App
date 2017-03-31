//
//  FRSHomeViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSHomeViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSSearchViewController.h"
#import "FRSLoginViewController.h"
#import "DGElasticPullToRefresh.h"
#import "FRSGalleryTableViewCell.h"
#import "FRSLoadingTableViewCell.h"
#import "FRSAwkwardView.h"
#import "FRSAlertView.h"
#import "MagicalRecord.h"
#import "FRSCoreData.h"
#import "FRSGallery+CoreDataProperties.h"
#import "FRSFollowingTable.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSNotificationHandler.h"
#import "FRSModerationManager.h"
#import "FRSGalleryManager.h"
#import "FRSNewPasswordAlertView.h"
#import "FRSTOSAlertView.h"
#import "NSDate+Fresco.h"
#import "NSString+Fresco.h"

static NSInteger const galleriesPerPage = 12;

@interface FRSHomeViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    BOOL isLoading;
    NSInteger lastOffset;
    BOOL shouldAnimate;
}

@property (strong, nonatomic) NSMutableArray *cachedData;
@property (strong, nonatomic) NSManagedObjectContext *temp;
@property (strong, nonatomic) NSMutableArray *highlights;
@property (strong, nonatomic) NSArray *followingGalleries;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIButton *highlightTabButton;
@property (strong, nonatomic) UIButton *followingTabButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *pulled;
@property (weak, nonatomic) FRSAppDelegate *appDelegate;
@property (nonatomic, strong) FRSFollowingTable *followingTable;
@property (nonatomic) bool isInHighlights;
@property (nonatomic) bool isInFollowers;

@property (strong, nonatomic) UIView *sudoNavBar;
@property (strong, nonatomic) FRSTOSAlertView *TOSAlert;
@property (strong, nonatomic) FRSNewPasswordAlertView *migrationAlert;

@end

@implementation FRSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cachedData = [[NSMutableArray alloc] init];
    reloadedFrom = [[NSMutableArray alloc] init];
    if (!self.appDelegate) {
        self.appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    self.temp = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [self configureUI];
    [self addNotificationObservers];

    [self configureFollowing];
    [self configureNavigationBar];

    self.scrollView.delegate = self;

    self.isInHighlights = true;
    self.isInFollowers = true;

    [self displayPreviousTab];

    [[FRSModerationManager sharedInstance] checkSuspended];

    //Unable to logout using delegate method because that gets called in LoginVC
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification) name:@"logout_notification" object:nil];

    if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
        [self checkStatusAndPresentPermissionsAlert];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self addStatusBarNotification];

    [FRSTracker screen:@"Home"];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.tabBarController.tabBar setHidden:NO];

    [self.tabBarController.navigationController setNavigationBarHidden:YES];
    [[FRSUserManager sharedInstance] reloadUser];
    [self.appDelegate startNotificationTimer];
    entry = [NSDate date];
    numberRead = 0;

    [self presentMigrationAlert];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self showTabBarAnimated:YES];

    if (hasLoadedOnce) {
        [self reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (entry) {
        exit = [NSDate date];
        NSInteger sessionLength = [exit timeIntervalSinceDate:entry];
        [FRSTracker track:highlightsSession
               parameters:@{ activityDuration : @(sessionLength),
                             @"galleries_scrolled_past" : @(numberRead) }];
    }

    [self removeStatusBarNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSPlayerPlay" object:self];
    [self expandNavBar:nil animated:NO];
}

- (void)logoutNotification {
    [self logoutWithPop:NO];
}

- (void)presentNewStuffWithPassword:(BOOL)password {
    if (self.migrationAlert) {
        return;
    }

    self.migrationAlert = [[FRSNewPasswordAlertView alloc] initNewStuffWithPasswordField:password];
    self.migrationAlert.delegate = self;
    [self.migrationAlert show];
}

- (void)presentWithTOS:(NSString *)tos {
    if (self.TOSAlert) {
        return;
    }

    self.TOSAlert = [[FRSTOSAlertView alloc] initWithTOS:tos];
    self.TOSAlert.delegate = self;
    [self.TOSAlert show];
}

- (BOOL)shouldHaveTextLimit {
    return YES;
}

- (void)scrollToTop {
    [self.followingTable scrollRectToVisible:CGRectMake(0, 0, self.followingTable.frame.size.width, self.followingTable.frame.size.height) animated:YES];
}

- (void)configureFollowing {
    CGRect scrollFrame = self.tableView.frame;
    scrollFrame.origin.x = scrollFrame.size.width;
    scrollFrame.origin.y = -64;

    self.followingTable = [[FRSFollowingTable alloc] initWithFrame:scrollFrame];
    self.followingTable.navigationController = self.navigationController;
    self.followingTable.leadDelegate = (id<FRSFollowingTableDelegate>)self;

    [self.pageScroller addSubview:self.followingTable];
    self.followingTable.scrollDelegate = self;
}

- (void)expandGallery:(FRSGallery *)gallery {
    [self galleryClicked:gallery];
}

- (void)logoutAlertAction {
    if ([[FRSUserManager sharedInstance] authenticatedUser].username) {
        return;
    }
    [self logoutWithPop:YES];
    self.TOSAlert = nil;
    self.migrationAlert = nil;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]]) {
        [(FRSGalleryTableViewCell *)cell offScreen];
    }
}

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configureDataSource];
    [self configurePullToRefresh];
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMigrationAlert) name:@"user-did-login" object:nil];

    if ([[FRSUserManager sharedInstance] authenticatedUser]) {
        if (![[FRSUserManager sharedInstance] authenticatedUser].username) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAlertAction) name:UIApplicationWillTerminateNotification object:nil];
        }
    }
}

- (void)presentMigrationAlert {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] != nil
        && ![[[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] boolValue]
        && ![[[NSUserDefaults standardUserDefaults] valueForKey:userHasFinishedMigrating] boolValue]
        && [[NSUserDefaults standardUserDefaults] valueForKey:userHasFinishedMigrating] != nil) {

        [self logoutWithPop:NO];

        return;
    }

    if ([[FRSAuthManager sharedInstance] isAuthenticated] && [[[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] boolValue]) {
        FRSNewPasswordAlertView *alert = [[FRSNewPasswordAlertView alloc] initNewStuffWithPasswordField:[[[NSUserDefaults standardUserDefaults] valueForKey:@"needs-password"] boolValue]];
        alert.delegate = self;
        [alert show];
        [FRSTracker track:migrationShown];
    }
}

- (void)reloadData {
    [self.followingTable reloadFollowing];

    [[FRSGalleryManager sharedInstance] fetchGalleriesWithLimit:galleriesPerPage
                                                offsetGalleryID:nil
                                                     completion:^(NSArray *galleries, NSError *error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self.tableView dg_stopLoading];
                                                         [self.followingTable dg_stopLoading];
                                                         isLoading = NO;
                                                       });
                                                       if (error) {
                                                           return;
                                                       }
                                                       [self.appDelegate.coreDataController.managedObjectContext performBlock:^{
                                                         NSInteger index = 0;
                                                         NSMutableArray *newGalleries = [[NSMutableArray alloc] init];
                                                         for (NSDictionary *gallery in galleries) {
                                                             NSString *galleryID = gallery[@"id"];
                                                             NSInteger galleryIndex = [self galleryExists:galleryID];
                                                             // Gallery does not exist -- create it in persistence layer & volotile memory
                                                             if (galleryIndex < 0 || galleryIndex >= self.dataSource.count) {
                                                                 FRSGallery *galleryToSave = [FRSGallery MR_createEntityInContext:self.appDelegate.coreDataController.managedObjectContext];

                                                                 [galleryToSave configureWithDictionary:gallery context:[self.appDelegate.coreDataController managedObjectContext]];
                                                                 [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
                                                                 [newGalleries addObject:galleryToSave];
                                                                 index++;
                                                                 continue;
                                                             }

                                                             // Gallery already exists, update its index & meta information (things change)
                                                             FRSGallery *galleryToSave = [self.dataSource objectAtIndex:galleryIndex];
                                                             [galleryToSave configureWithDictionary:gallery context:[self.appDelegate.coreDataController managedObjectContext]];
                                                             [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
                                                             [newGalleries addObject:galleryToSave];
                                                             index++;
                                                         }

                                                         //Set new data source, reload the table view, stop and hide spinner (crucial to insure its on the main thread)

                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                           self.dataSource = newGalleries;
                                                           [self.tableView reloadData];
                                                         });
                                                       }];
                                                     }];
}

#pragma mark - UI

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

- (void)configurePullToRefresh {
    loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor frescoBlueColor];

    __weak typeof(self) weakSelf = self;

    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0
                                         minOffsetToPull:80
                                     loadingContentInset:44
                                         loadingViewSize:20
                                                velocity:0
                                           actionHandler:^{
                                             [weakSelf reloadData];
                                           }
                                             loadingView:loadingView
                                                    yPos:0];

    [self.tableView dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (needsUpdate) {
        needsUpdate = NO;
    }

    if (scrollView == self.pageScroller) {
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (needsUpdate) {
        needsUpdate = NO;
    }
}

- (void)dealloc {
    [self.tableView dg_removePullToRefresh];
}

- (void)configureNavigationBar {
    [self removeNavigationBarLine];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;

    self.highlightTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 10 - titleView.frame.size.width / 6, 6, 120, 30)];
    [self.highlightTabButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [self.highlightTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.highlightTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.highlightTabButton addTarget:self action:@selector(handleHighlightsTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.highlightTabButton];

    self.followingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 10 + titleView.frame.size.width / 6, 6, 120, 30)];
    self.followingTabButton.alpha = 0.7;
    [self.followingTabButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.followingTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.followingTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followingTabButton addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.followingTabButton];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    /* Configure sudo nav bar when scrolling for scrolling between tabs and nav bar is hidden */
    self.sudoNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, -88, self.view.frame.size.width, 44)];
    self.sudoNavBar.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:self.sudoNavBar];

    UIButton *sudoHighlightButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 10 - titleView.frame.size.width / 6, 6, 120, 30)];
    [sudoHighlightButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [sudoHighlightButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoHighlightButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoHighlightButton];

    UIButton *sudoFollowingButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 10 + titleView.frame.size.width / 6, 6, 120, 30)];
    [sudoFollowingButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [sudoFollowingButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoFollowingButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoFollowingButton];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count > indexPath.row) {
        FRSGallery *gallery = [self.dataSource objectAtIndex:indexPath.row];
        return [gallery heightForGallery];
    }

    return 10;
}

- (void)configureTableView {
    [super configureTableView];

    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSGalleryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:galleryCellIdentifier];
    self.tableView.frame = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 20);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = YES;
    self.pageScroller.delegate = self;

    [self.view addSubview:self.pageScroller];
}

- (void)configureDataSource {
    // make core data fetch
    [self fetchLocalData];

    // network call
    [[FRSGalleryManager sharedInstance] fetchGalleriesWithLimit:galleriesPerPage
                                                offsetGalleryID:nil
                                                     completion:^(NSArray *galleries, NSError *error) {
                                                       if ([galleries count] == 0) {

                                                       } else {
                                                           [self cacheLocalData:galleries];
                                                       }

                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self.loadingView stopLoading];
                                                         [self.loadingView removeFromSuperview];
                                                         hasLoadedOnce = TRUE;
                                                       });
                                                     }];
}


/**
 Fetches galleries from local store
 */
- (void)fetchLocalData {
    NSManagedObjectContext *moc = [self.appDelegate.coreDataController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSGallery"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE] ];
    
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    
    pulledFromCache = stored;
    
    self.dataSource = [NSMutableArray arrayWithArray:stored];
    self.highlights = self.dataSource;
    
    if ([_dataSource count] > 0) {
        [self.loadingView stopLoading];
        [self.loadingView removeFromSuperview];
    } else {
        if ([self.dataSource count] == 0) {
            [self configureSpinner];
        }
    }
    
    self.cachedData = [NSMutableArray arrayWithArray:stored];
    [self.tableView reloadData];
}

- (NSInteger)galleryExists:(NSString *)galleryID {
    NSInteger index = 0;

    for (FRSGallery *gallery in self.dataSource) {
        NSString *uid = gallery.uid;
        if ([uid isEqualToString:galleryID]) {
            return index;
        }

        index++;
    }

    return -1;
}

- (void)cacheLocalData:(NSArray *)localData {
    if (self.appDelegate.coreDataController.managedObjectContext) {
        [self.appDelegate.coreDataController.managedObjectContext performBlock:^{
          self.dataSource = [[NSMutableArray alloc] init];
          self.highlights = [[NSMutableArray alloc] init];

          NSInteger localIndex = 0;
          for (NSDictionary *gallery in localData) {
              FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[self.appDelegate.coreDataController managedObjectContext]];

              [galleryToSave configureWithDictionary:gallery context:[self.appDelegate.coreDataController managedObjectContext]];
              [galleryToSave setValue:[NSNumber numberWithInteger:localIndex] forKey:@"index"];
              [self.dataSource addObject:galleryToSave];
              [self.highlights addObject:galleryToSave];
              localIndex++;
          }

          if ([self.appDelegate.coreDataController.managedObjectContext hasChanges]) {
              @try {
                  [self.appDelegate.coreDataController.managedObjectContext save:Nil];
              }
              @catch (NSException *exception) {
                  NSLog(@"Exception:%@", exception);
              }
          }

          [self.appDelegate saveContext];

          [self.tableView reloadData];

          for (FRSGallery *gallery in self.cachedData) {
              [self.appDelegate.coreDataController.managedObjectContext deleteObject:gallery];
          }

          [self.appDelegate saveContext];
        }];
    }

}

- (void)reloadFromLocal {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (shouldAnimate) {
          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
      } else {
          [self.tableView reloadData];
      }
    });
}

#pragma mark - UITableView DataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 125)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 125;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return (self.dataSource.count == 0 || self.loadNoMore) ? self.dataSource.count : self.dataSource.count + 1;
    }

    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) {
        return loadingCellHeight;
    }

    if (tableView == self.tableView) {
        return [self heightForItemAtDataSourceIndex:indexPath.row];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath) {
        return [self highlightCellForIndexPath:indexPath];
    }

    return nil;
}

- (UITableViewCell *)highlightCellForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSource.count && self.dataSource.count != 0 && self.dataSource != nil) {
        FRSLoadingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }

    FRSGalleryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:galleryCellIdentifier];
    cell.navigationController = self.navigationController;
    cell.gallery = self.dataSource[indexPath.row];
    cell.navigationController = self.navigationController;
    cell.trackedScreen = FRSTrackedScreenHighlights;

    dispatch_async(dispatch_get_main_queue(), ^{
      [cell configureCell];
    });

    __weak typeof(self) weakSelf = self;

    cell.shareBlock = ^void(NSArray *sharedContent) {
      [weakSelf showShareSheetWithContent:sharedContent];
    };

    cell.readMoreBlock = ^(NSArray *bullshit) {
      [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
    };

    cell.delegate = self;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (void)loadMore {
    if (!hasLoadedOnce) {
        return;
    }

    isLoading = TRUE;
    FRSGallery *lastGallery = [self.dataSource lastObject];
    NSString *offsetID = lastGallery.uid;

    if ([reloadedFrom containsObject:offsetID]) {
        return;
    }

    [reloadedFrom addObject:offsetID];

    if (lastOffset == self.dataSource.count) {
        return;
    }

    lastOffset = self.dataSource.count;

    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

    [[FRSGalleryManager sharedInstance] fetchGalleriesWithLimit:galleriesPerPage
                                                offsetGalleryID:offsetID
                                                     completion:^(NSArray *galleries, NSError *error) {
                                                       if ([galleries count] == 0) {
                                                           self.loadNoMore = TRUE;
                                                           [self.tableView reloadData];
                                                           return;
                                                       }

                                                       [[[self.appDelegate coreDataController] managedObjectContext] performBlock:^{
                                                         NSInteger index = self.highlights.count;
                                                         for (NSDictionary *gallery in galleries) {
                                                             FRSGallery *galleryToSave = [NSEntityDescription
                                                                 insertNewObjectForEntityForName:@"FRSGallery"
                                                                          inManagedObjectContext:[self.appDelegate.coreDataController managedObjectContext]];

                                                             [galleryToSave configureWithDictionary:gallery context:[self.appDelegate.coreDataController managedObjectContext]];
                                                             [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
                                                             [self.dataSource addObject:galleryToSave];
                                                             [self.highlights addObject:galleryToSave];
                                                             [indexPaths addObject:[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0]];
                                                             index++;
                                                         }

                                                         [self.appDelegate saveContext];

                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                           //                [self.tableView beginUpdates];
                                                           //                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                                           //                [self.tableView endUpdates];
                                                           [self.tableView reloadData];
                                                           needsUpdate = TRUE;
                                                           isLoading = FALSE;
                                                         });
                                                       }];
                                                     }];
}

- (void)playerWillPlay:(AVPlayer *)play {
    //    for (UITableView *tableView in @[self.tableView, self.followingTable]) {
    //        NSArray *visibleCells = [tableView visibleCells];
    //        for (FRSGalleryTableViewCell *cell in visibleCells) {
    //            if (![[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]] || !cell.galleryView.players) {
    //                continue;
    //            }
    //            for (FRSPlayer *player in cell.galleryView.players) {
    //                if (player != play && [[player class] isSubclassOfClass:[FRSPlayer class]]) {
    //                    [player pause];
    //                }
    //            }
    //        }
    //    }
}

- (NSInteger)heightForItemAtDataSourceIndex:(NSInteger)index {

    if (index == self.dataSource.count) {
        return 20;
    }

    FRSGallery *gallery = self.dataSource[index];
    return [gallery heightForGallery];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryTableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    if (tableView == self.tableView) {

        if (indexPath.row > numberRead) {
            numberRead = indexPath.row;
        }

        if (indexPath.row == self.dataSource.count - 4) {
            if (!isLoading && !self.loadNoMore) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                  [self loadMore];
                });
            }
        }
    }
}

- (void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
    NSString *url = content[0];
    url = [[url componentsSeparatedByString:@"/"] lastObject];
    [FRSTracker track:galleryShared
           parameters:@{ @"gallery_id" : url,
                         @"shared_from" : @"highlights" }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)galleryClicked:(FRSGallery *)gallery {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    vc.gallery = gallery;
    [vc configureBackButtonAnimated:YES];
    vc.openedFrom = @"following";

    self.navigationItem.title = @"";

    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];
}

- (void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)notification {

    FRSGallery *gallery = self.dataSource[notification.row];
    [FRSTracker track:galleryOpenedFromHighlights
           parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"",
                         @"opened_from" : @"highlights" }];

    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    [vc configureBackButtonAnimated:YES];
    vc.gallery = gallery;
    vc.openedFrom = @"highlights";

    self.navigationItem.title = @"";

    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];
}

#pragma mark - Nav Bar Actions

- (void)handleFollowingTabTapped {
    if (self.followingTabButton.alpha > 0.7) {
        return; //The button is already selected
    }

    [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];

    self.followingTabButton.alpha = 1.0;
    self.highlightTabButton.alpha = 0.7;
}

- (void)handleHighlightsTabTapped {
    if (self.highlightTabButton.alpha > 0.7) {
        return;
    }
    [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];

    self.highlightTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;
}

- (void)searchStories {
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //self.sudoNavBar.frame = CGRectMake(0, (scrollView.contentOffset.x/8.5)-88, self.view.frame.size.width, 44);

    // Check if horizontal scrollView to avoid issues with potentially conflicting scrollViews

    //Make the nav bar expand relative to the x offset
    [super scrollViewDidScroll:scrollView];

    //    NSMutableArray *barButtonItems = [NSMutableArray array];
    //    [barButtonItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    //    [barButtonItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    //    float navBarHeight=20.0;
    //    float scrollingDifferenceX = (scrollView.contentOffset.x/self.tableView.frame.size.width*(navBarHeight*2))-navBarHeight-3;

    //NSLog(@"TABLEVIEW WIDTH: %f",self.tableView.frame.size.width);
    //NSLog(@"CONTENT X: %f",scrollView.contentOffset.x);
    //NSLog(@"SCROLLING Y: %f",scrollingDifference);

    if (scrollView == self.pageScroller) {
        self.loadingView.alpha = 1 - (scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.frame.size.width));

        [self pausePlayers];
        if (self.pageScroller.contentOffset.x == self.view.frame.size.width) { // User is in right tab (following)
            self.followingTabButton.alpha = 1;
            self.highlightTabButton.alpha = 0.7;

            [self.tableView dg_stopLoading];
            [self.followingTable dg_stopLoading];

            [self.tableView dg_removePullToRefresh];
            loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            loadingView.tintColor = [UIColor frescoBlueColor];

            __weak typeof(self) weakSelf = self;
            [self.followingTable dg_addPullToRefreshWithWaveMaxHeight:0
                                                      minOffsetToPull:80
                                                  loadingContentInset:44
                                                      loadingViewSize:20
                                                             velocity:0
                                                        actionHandler:^{
                                                          [weakSelf reloadData];
                                                        }
                                                          loadingView:loadingView
                                                                 yPos:0];

            [self.followingTable dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
            [self.followingTable dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }

        if (self.pageScroller.contentOffset.x == 0) { // User is in left tab (highlights)
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldDisplayFollowing"];
            self.isInHighlights = true;
            self.isInFollowers = false;
            self.followingTabButton.alpha = 0.7;
            self.highlightTabButton.alpha = 1;
            [self.tableView dg_stopLoading];
            [self.followingTable dg_stopLoading];

            [self.followingTable dg_removePullToRefresh];

            loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            loadingView.tintColor = [UIColor frescoBlueColor];

            __weak typeof(self) weakSelf = self;
            [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0
                                                 minOffsetToPull:80
                                             loadingContentInset:44
                                                 loadingViewSize:20
                                                        velocity:0
                                                   actionHandler:^{
                                                     [weakSelf reloadData];
                                                   }
                                                     loadingView:loadingView
                                                            yPos:0];

            [self.tableView dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
            [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        } else if (self.pageScroller.contentOffset.x == self.tableView.frame.size.width) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldDisplayFollowing"];
            self.isInHighlights = false;
            self.isInFollowers = true;
        }
    }

    if (scrollView == self.tableView) {

        CGPoint currentOffset = scrollView.contentOffset;
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
        if (timeDiff > 0.1) {
            CGFloat distance = currentOffset.y - lastScrollOffset.y;
            //The multiply by 10, / 1000 isn't really necessary.......
            CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond

            CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
            if (scrollSpeed > maxScrollVelocity) {
                isScrollingFast = YES;
            } else {
                isScrollingFast = NO;
            }

            lastScrollOffset = currentOffset;
            lastOffsetCapture = currentTime;
        }

        NSArray *visibleCells = [self.tableView visibleCells];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          BOOL taken = FALSE;

          for (FRSGalleryTableViewCell *cell in visibleCells) {

              /*
                 Start playback mid frame -- at least 300 from top & at least 100 from bottom
                 */
              if (cell.frame.origin.y - self.tableView.contentOffset.y < 300 && cell.frame.origin.y - self.tableView.contentOffset.y > 0) {

                  if (!taken) {

                      if ([cell respondsToSelector:@selector(play)] && !isScrollingFast) {
                          taken = TRUE;
                          [cell play];
                      }
                  }

              } else {
                  if ([cell respondsToSelector:@selector(play)]) {
                      [cell pause];
                  }
              }
          }

          if (!taken) {
              lastIndexPath = Nil;
          }
        });
    }
}

- (void)displayPreviousTab {
    //Checks which tab the user left the view from and displays it on next launch

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldDisplayFollowing"]) {
        [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
        self.followingTabButton.alpha = 1.0;
        self.highlightTabButton.alpha = 0.7;

    } else {
        [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];
        self.highlightTabButton.alpha = 1.0;
        self.followingTabButton.alpha = 0.7;
    }
}

- (void)pausePlayers {

    for (UITableView *tableView in @[ self.tableView, self.followingTable ]) {
        for (FRSGalleryTableViewCell *cell in [tableView visibleCells]) {
            if (![[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]]) {
                continue;
            }
            [cell pause];
        }
    }
}

@end
