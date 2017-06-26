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
#import "FRSUserStory+CoreDataClass.h"
#import "FRSFollowingTable.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSNotificationHandler.h"
#import "FRSModerationManager.h"
#import "FRSGalleryManager.h"
#import "FRSTOSAlertView.h"
#import "NSDate+Fresco.h"
#import "NSString+Fresco.h"
#import "FRSUserStoryManager.h"
#import "FRSStoryTableViewCell.h"

static NSInteger const galleriesPerPage = 12;

@interface FRSHomeViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    BOOL isLoading;
    NSInteger lastOffset;
    BOOL shouldAnimate;
}

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

@property (strong, nonatomic) FRSTOSAlertView *TOSAlert;
@property (assign, nonatomic) BOOL isScrolling;
@property (assign, nonatomic) BOOL shouldAutoPlayWithoutUserInteraction;

@end

@implementation FRSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.highlights = [[NSMutableArray alloc] init];
    
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
        [self checkStatusAndPresentPermissionsAlert:NO];
    }
    
    //video cell loaded notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoCellLoaded:) name:FRSGalleryMediaVideoCollectionViewCellLoadedPost object:nil];
    
    self.shouldAutoPlayWithoutUserInteraction = YES;
    
    [self configureDataSourceOnLoad];
    
    
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTabBarAnimated:YES];
    
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

-(void)videoCellLoaded:(NSNotification *)notification {
    if(self.shouldAutoPlayWithoutUserInteraction) {
        [self handlePlay];
    }
}

- (void)logoutNotification {
    [self logoutWithPop:NO];
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
    [self pausePlayers];
    
    if(self.followingTabButton.alpha == 1 && self.followingTable.feed.count > 0) {
        [self.followingTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }else if(self.highlightTabButton.alpha == 1 && self.highlights.count > 0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else {
        //ideally we should not get this case. But if we get, we scroll both the tables to top.
        if(self.followingTable.feed.count > 0) {
            [self.followingTable scrollRectToVisible:CGRectMake(0, 0, self.followingTable.frame.size.width, self.followingTable.frame.size.height) animated:YES];
        }
        if(self.highlights.count > 0){
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:YES];
        }
    }
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
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]]) {
        [(FRSGalleryTableViewCell *)cell offScreen];
    }
}

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configurePullToRefresh];
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];
    
    if ([[FRSUserManager sharedInstance] authenticatedUser]) {
        if (![[FRSUserManager sharedInstance] authenticatedUser].username) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAlertAction) name:UIApplicationWillTerminateNotification object:nil];
        }
    }
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    
    [self.followingTable reloadFollowing];
    
    [[FRSGalleryManager sharedInstance] fetchGalleriesWithLimit:galleriesPerPage
                                                offsetGalleryID:nil
                                                     completion:^(NSArray *galleries, NSError *error) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf.tableView dg_stopLoading];
                                                             [weakSelf.followingTable dg_stopLoading];
                                                             isLoading = NO;
                                                         });
                                                         if (error) {
                                                             return;
                                                         }
                                                         
                                                         [weakSelf handlePullToRefreshedData:galleries];
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
    
    self.disableCollapse = YES;
    
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
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.highlights.count > indexPath.row) {
        return 280.0;
    }
    
    return 10;
}

- (void)configureTableView {
    [super configureTableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSGalleryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:galleryCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSStoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyCellIdentifier];

    self.tableView.frame = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 20);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = YES;
    self.pageScroller.delegate = self;
    
    [self.view addSubview:self.pageScroller];
}

- (void)configureDataSourceOnLoad {
    if([FRSReachability isCurrentlyConnectedToInternet]) {
        //delete all galleries from core data if this is success.
        [self initialFetchFromServer];
    }
    else {
        // make core data fetch
        [self fetchLocalData];
    }
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
    
    self.highlights = [NSMutableArray arrayWithArray:stored];
    
    if ([self.highlights count] > 0) {
        [self.loadingView stopLoading];
        [self.loadingView removeFromSuperview];
    } else {
        if ([self.highlights count] == 0) {
            [self configureSpinner];
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger)galleryExists:(NSString *)galleryID {
    NSInteger index = 0;
    
    for (FRSGallery *gallery in self.highlights) {
        NSString *uid = gallery.uid;
        if ([uid isEqualToString:galleryID]) {
            return index;
        }
        
        index++;
    }
    
    return -1;
}

-(void)handlePullToRefreshedData:(NSArray *)refreshedGalleries {
    NSLog(@"Home VC handlePullToRefreshedData");
    
    //Now deleting the cache for every pull to refresh.
    [self deleteCache];
    //Now delete contents of the highlights array also.
    [self.highlights removeAllObjects];
    
    [self appendToLocalDataCache:refreshedGalleries];
    
    /*
     TODO: The following code is to check if the new data falls in between the cached data. If included, need rigorous testing for edge cases, where top gallery from the new list may fall in between any place. Also for metadata updates.
     
     //    revcheck Refreshed Galleries From Server Contain Current TopGallery
     //    If our top gallery is in the refreshed batch. just insert only new ones in highlightsArray, else delete cache and just have new ones.
     FRSGallery *topGallery;
     if (self.highlights.count>0) {
     topGallery = self.highlights[0];
     }
     if(!topGallery) {
     // need to directly save the new batch in core data and also display them.
     [self appendToLocalDataCache:refreshedGalleries];
     return;
     }
     
     NSArray *refreshedGalleriesIDs = [refreshedGalleries valueForKey:@"id"];
     
     if(refreshedGalleriesIDs.count == 0) {
     // need to directly save the new batch in core data and also display them.
     [self appendToLocalDataCache:refreshedGalleries];
     return;
     }
     
     if (![refreshedGalleriesIDs containsObject:topGallery.uid]) {
     //OK. The current displayed data on the table is outdated. Dont know how far way. So delete all teh cache from Core Data , also frm the local highlights array.
     //Start fresh.
     //need to directly save the new batch in core data and also display them.
     [self deleteCache];
     [self appendToLocalDataCache:refreshedGalleries];
     return;
     }
     
     //proceed to insert only the new ones.
     NSMutableArray *onlyNewGalleries = [[NSMutableArray alloc] initWithCapacity:refreshedGalleries.count];
     
     NSInteger index = 0;
     for(NSDictionary *gallery in refreshedGalleries) {
     NSString *galleryID = gallery[@"id"];
     if([galleryID isEqualToString:topGallery.uid]) {
     break;
     }
     else {
     FRSGallery *galleryToSave = [FRSGallery MR_createEntityInContext:self.appDelegate.coreDataController.managedObjectContext];
     
     [galleryToSave configureWithDictionary:gallery context:[self.appDelegate.coreDataController managedObjectContext]];
     [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
     [onlyNewGalleries addObject:galleryToSave];
     index++;
     }
     
     }
     
     [self.appDelegate.coreDataController saveContext];
     
     //update metadata
     [self updateHighlightsMetadataFromRefreshIndex:index fromArray:refreshedGalleries];
     
     [self.tableView reloadData];
     
     */
    
}

/*
-(void)updateHighlightsMetadataFromRefreshIndex:(NSInteger)index fromArray:(NSArray *)refreshedArray {
    NSInteger highlightsIndex = 0;
    
    //update metadata. Need to use only one for loop here.
    for(NSInteger i = index; i<refreshedArray.count && i<self.highlights.count; i++) {
        FRSGallery *galleryToSave = [self.highlights objectAtIndex:highlightsIndex];
        NSDictionary *fromRefreshedGallery = [refreshedArray objectAtIndex:i];
        
        NSString *refreshedGalleryID = fromRefreshedGallery[@"id"];
        
        //if id not found continue.
        if (!refreshedGalleryID) continue;
        
        if([refreshedGalleryID isEqualToString:galleryToSave.uid]) {
            [galleryToSave configureWithDictionary:fromRefreshedGallery context:[self.appDelegate.coreDataController managedObjectContext]];
        }
        
        highlightsIndex++;
    }
    
    //update index
    NSInteger newIndex = index;
    
    for(NSInteger i = newIndex; i<self.highlights.count; i++) {
        FRSGallery *galleryToSave = [self.highlights objectAtIndex:i];
        
        [galleryToSave setValue:[NSNumber numberWithInteger:newIndex] forKey:@"index"];
        newIndex++;
        
    }
    
    [self.appDelegate.coreDataController saveContext];
    
}
*/

- (void)appendToLocalDataCache:(NSArray *)localData {
    if (self.appDelegate.coreDataController.managedObjectContext) {
        [self.appDelegate.coreDataController.managedObjectContext performBlock:^{
            //localIndex = 0 for onLoad and internet avaolable
            NSInteger localIndex = self.highlights.count;
            for (NSDictionary *gallery in localData) {
                FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[self.appDelegate.coreDataController managedObjectContext]];
                
                [galleryToSave configureWithDictionary:gallery context:[self.appDelegate.coreDataController managedObjectContext]];
                [galleryToSave setValue:[NSNumber numberWithInteger:localIndex] forKey:@"index"];
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
            
            [self.appDelegate saveContext
             ];
            [self.tableView reloadData];
        }];
    }
    
}

- (void)appendToLocalDataCacheUserStories:(NSArray *)localData {
    if (self.appDelegate.coreDataController.managedObjectContext) {
        [self.appDelegate.coreDataController.managedObjectContext performBlock:^{
            //localIndex = 0 for onLoad and internet avaolable
            NSInteger localIndex = self.highlights.count;
            for (NSDictionary *userStoryDict in localData) {
                FRSUserStory *userStoryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUserStory" inManagedObjectContext:[self.appDelegate.coreDataController managedObjectContext]];
                
                [userStoryToSave configureWithDictionary:userStoryDict context:[self.appDelegate.coreDataController managedObjectContext]];
                [userStoryToSave setValue:[NSNumber numberWithInteger:localIndex] forKey:@"index"];
                [self.highlights addObject:userStoryToSave];
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
            
            [self.appDelegate saveContext
             ];
            [self.tableView reloadData];
        }];
    }
    
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
        return (self.highlights.count == 0 || self.loadNoMore) ? self.highlights.count : self.highlights.count + 1;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.highlights.count) {
        return loadingCellHeight;
    }
    
    if (tableView == self.tableView) {
        return [self heightForItemAtDataSourceIndex:indexPath.row];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath) {
        return [self highlightCellForIndexPathUserStory:indexPath];
    }
    
    return nil;
}

- (UITableViewCell *)highlightCellForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.highlights.count && self.highlights.count != 0 && self.highlights != nil) {
        FRSLoadingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    FRSGalleryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:galleryCellIdentifier];
    cell.navigationController = self.navigationController;
    cell.gallery = self.highlights[indexPath.row];
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
    return cell;
}

- (UITableViewCell *)highlightCellForIndexPathUserStory:(NSIndexPath *)indexPath {
    if (indexPath.row == self.highlights.count && self.highlights.count != 0 && self.highlights != nil) {
        FRSLoadingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    FRSStoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:storyCellIdentifier];
    cell.trackedScreen = FRSTrackedScreenHighlights;
    
    [cell clearCell];
    
    if (indexPath.row < self.highlights.count) {
        
        __weak typeof(self) weakSelf = self;
        cell.userStory = self.highlights[indexPath.row];
        
        cell.readMoreBlock = ^void(NSArray *sharedContent) {
            [weakSelf readMoreForUserStoryAtIndexPath:indexPath];
        };
        
        cell.shareBlock = ^void(NSArray *sharedContent) {
            [weakSelf showShareSheetWithContent:sharedContent];
        };
        
        [cell configureCell];
        cell.navigationController = self.navigationController;
        
    }
    return cell;
}

- (void)loadMore {
    
    FRSGallery *lastGallery = [self.highlights lastObject];
    NSString *offsetID = lastGallery.uid;
    
    [self fetchFromServerWithOffsetGalleryID:offsetID];
    
}

- (NSInteger)heightForItemAtDataSourceIndex:(NSInteger)index {
    
    if (index == self.highlights.count) {
        return 20;
    }
    
    FRSUserStory *userStory = self.highlights[index];
    return [userStory heightForUserStory];
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
        
        if (indexPath.row == self.highlights.count - 4) {
            if (!isLoading && !self.loadNoMore) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [weakSelf loadMore];
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
    NSLog(@"Home VC didReceiveMemoryWarning");
    //Deleting the cache from the core data deletes the objects in the highlights array as well and results in wierd issues like crashes/miscalclutaion of heightForGallery. Because highlights array has reference to the same object.
    //Also NSManagedObject class does not conform to NSCopying protocol to implement copyWithZone method and copy the objects into a different instance.
    //We actually need to use our own model objects instead of directly using the coredata managed object instances.
    //Then delete the core data cache. We will still have model objects which are copied originally from managed objects.
    //deleteCache is not the correct solution right now for memory warnings.
    //    [self deleteCache];
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
    
    FRSGallery *gallery = self.highlights[notification.row];
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

- (void)readMoreForUserStoryAtIndexPath:(NSIndexPath *)indexPath {
    FRSUserStory *userStory = self.highlights[indexPath.row];
    NSLog(@"Read More for User Story: %@", userStory);
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
    self.shouldAutoPlayWithoutUserInteraction = NO;
    
    //Make the nav bar expand relative to the x offset
    [super scrollViewDidScroll:scrollView];
    
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
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(self.isScrolling){
        if(!decelerate){
            self.isScrolling = NO;
            [self handlePlay];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (needsUpdate) {
        needsUpdate = NO;
    }
    
    if(self.isScrolling){
        self.isScrolling = NO;
        [self handlePlay];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
    [self pausePlayers];
}

-(void)handlePlay {
    NSLog(@"handlePlay");
    
    [self pausePlayers];
    
    for (FRSGalleryTableViewCell *cell in self.tableView.visibleCells) {
        /*
         Start playback mid frame -- at least 60% of the table.
         */
        if (![cell isKindOfClass:[FRSGalleryTableViewCell class]]) continue;
        
        if (cell.frame.origin.y - self.tableView.contentOffset.y < 0.6*self.tableView.frame.size.height && cell.frame.origin.y - self.tableView.contentOffset.y > 0) {
            NSLog(@"playing from handle play cell: \n%@ \n%@", cell, [self.tableView indexPathForCell:cell]);
            [cell play];
            break;
        }
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

#pragma mark - DataManager

- (void)initialFetchFromServer {
    __weak typeof(self) weakSelf = self;
    
    [self.followingTable reloadFollowing];
    
    // network call
    [[FRSUserStoryManager sharedInstance] fetchUserStoriesWithLimit:galleriesPerPage offsetStoryID:nil completion:^(NSArray *userStories, NSError *error) {
        NSLog(@"Story responseObject: %@ \n error: %@", userStories, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingView stopLoading];
            [weakSelf.loadingView removeFromSuperview];
            hasLoadedOnce = TRUE;
            [weakSelf.tableView reloadData];
        });
        
        if (error && error.code == -1009) {
            // no internet
        }
        
        if ([userStories count] == 0) {
            //if needed reload only the loading cell to remove loading.
        } else {
            //since this is initial load, delete the previous entries.
            NSLog(@"Home VC initial load");
            
            [weakSelf deleteCacheUserStories];
            //Now delete contents of the highlights array also.
            [self.highlights removeAllObjects];
            
            //add new entries to cache.
            [weakSelf appendToLocalDataCacheUserStories:userStories];
        }

    }];
    /*
    [[FRSGalleryManager sharedInstance] fetchGalleriesWithLimit:galleriesPerPage
                                                offsetGalleryID:nil
                                                     completion:^(NSArray *galleries, NSError *error) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf.loadingView stopLoading];
                                                             [weakSelf.loadingView removeFromSuperview];
                                                             hasLoadedOnce = TRUE;
                                                             [weakSelf.tableView reloadData];
                                                         });
                                                         
                                                         if (error && error.code == -1009) {
                                                             // no internet
                                                         }
                                                         
                                                         if ([galleries count] == 0) {
                                                             //if needed reload only the loading cell to remove loading.
                                                         } else {
                                                             //since this is initial load, delete the previous entries.
                                                             NSLog(@"Home VC initial load");
                                                             
                                                             [weakSelf deleteCache];
                                                             //Now delete contents of the highlights array also.
                                                             [self.highlights removeAllObjects];
                                                             
                                                             //add new entries to cache.
                                                             [weakSelf appendToLocalDataCache:galleries];
                                                         }
                                                         
                                                         
                                                     }];
     */
    
}

-(void)fetchFromServerWithOffsetGalleryID:(NSString *)offsetGalleryID {
    // network call
    __weak typeof(self) weakSelf = self;
    
    isLoading = TRUE;
    
    [[FRSGalleryManager sharedInstance] fetchGalleriesWithLimit:galleriesPerPage
                                                offsetGalleryID:offsetGalleryID
                                                     completion:^(NSArray *galleries, NSError *error) {
                                                         isLoading = FALSE;
                                                         
                                                         if ([galleries count] == 0) {
                                                             
                                                         } else {
                                                             [weakSelf appendToLocalDataCache:galleries];
                                                         }
                                                         
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf.loadingView stopLoading];
                                                             [weakSelf.loadingView removeFromSuperview];
                                                             hasLoadedOnce = TRUE;
                                                             
                                                         });
                                                     }];
    
}

-(void)deleteCache {
    NSLog(@"Deleting Cached Galleries");
    
    //Can directly execute a delete request for all galleries at once, using a predicate. we need not do a for loop here.
    
    NSManagedObjectContext *moc = [self.appDelegate.coreDataController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSGallery"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE] ];
    
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    
    for (FRSGallery *gallery in stored) {
        [self.appDelegate.coreDataController.managedObjectContext deleteObject:gallery];
    }
    
    [self.appDelegate saveContext];
    
}

-(void)deleteCacheUserStories {
    NSLog(@"Deleting Cached user stories");
    
    //Can directly execute a delete request for all galleries at once, using a predicate. we need not do a for loop here.
    
    NSManagedObjectContext *moc = [self.appDelegate.coreDataController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSUserStory"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE] ];
    
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    
    for (FRSUserStory *userStory in stored) {
        [self.appDelegate.coreDataController.managedObjectContext deleteObject:userStory];
    }
    
    [self.appDelegate saveContext];
    
}



@end
