//
//  FRSHomeViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSHomeViewController.h"
#import "Fresco.h"

/* View Controllers */
#import "FRSGalleryExpandedViewController.h"
#import "FRSSearchViewController.h"

/* UI */
#import "DGElasticPullToRefresh.h"
#import "FRSGalleryCell.h"
#import "FRSTrimTool.h"
#import "FRSAwkwardView.h"

/* Core Data */
#import "MagicalRecord.h"
#import "FRSCoreData.h"
#import "FRSAppDelegate.h"
#import "FRSGallery+CoreDataProperties.h"
#import "FRSFollowingTable.h"

@interface FRSHomeViewController () <UITableViewDataSource, UITableViewDelegate>
{
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
//@property (strong, nonatomic) CAShapeLayer *maskView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *pulled;
@property (weak, nonatomic) FRSAppDelegate *appDelegate;
@property (nonatomic, strong) FRSFollowingTable *followingTable;
@property (nonatomic) bool isInHighlights;
@property (nonatomic) bool isInFollowers;

@property (strong, nonatomic) UIView *sudoNavBar;

@end

@implementation FRSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cachedData = [[NSMutableArray alloc] init];
    
    reloadedFrom = [[NSMutableArray alloc] init];
    if (!self.appDelegate) {
        self.appDelegate = [[UIApplication sharedApplication] delegate];
    }
    self.temp = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];

    [self configureUI];
    [self addNotificationObservers];
    
    [self configureFollowing];
    [self configureNavigationBar];

    self.scrollView.delegate = self;
    
    self.isInHighlights = true;
    self.isInFollowers = true;
}

-(BOOL)shouldHaveTextLimit {
    return YES;
}

-(void)loadData {
    
}

-(void)configureFollowing {
    CGRect scrollFrame = self.tableView.frame;
    scrollFrame.origin.x = scrollFrame.size.width;
    scrollFrame.origin.y = -64;
    
    self.followingTable = [[FRSFollowingTable alloc] initWithFrame:scrollFrame];
    self.followingTable.navigationController = self.navigationController;
    //[self configureNoFollowers];
    
    [self.pageScroller addSubview:self.followingTable];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addStatusBarNotification];
    [self showNavBarForScrollView:self.scrollView animated:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self.appDelegate reloadUser];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTabBarAnimated:YES];
    
    if (hasLoadedOnce) {
        [self reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self removeStatusBarNotification];
    [self pausePlayers];
}

-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configureDataSource];
    [self configurePullToRefresh];
}

-(void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];
}

-(void)reloadData {
    [self.followingTable reloadFollowing];
    
    [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:self.dataSource.count offsetGalleryID:Nil completion:^(NSArray *galleries, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSInteger index = 0;
            
            for (NSDictionary *gallery in galleries) {
                NSString *galleryID = gallery[@"id"];
                NSInteger galleryIndex = [self galleryExists:galleryID];
                
                if (galleryIndex == -1) {
                    FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[self.appDelegate managedObjectContext]];
                    
                    [galleryToSave configureWithDictionary:gallery context:[self.appDelegate managedObjectContext]];
                    [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
                    [self.dataSource insertObject:galleryToSave atIndex:index];
                }
                else {
                    FRSGallery *galleryToSave = [self.dataSource objectAtIndex:galleryIndex];
                    [galleryToSave configureWithDictionary:gallery context:[self.appDelegate managedObjectContext]];
                    [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
                }
                
                index++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                isLoading = FALSE;
                [self.tableView dg_stopLoading];
                [self.followingTable dg_stopLoading];
            });
        });
    }];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    FRSGalleryCell *galleryCell = (FRSGalleryCell *)cell;
    if ([galleryCell respondsToSelector:@selector(pause)]) {
        [galleryCell pause];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 90)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 93;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


#pragma mark - UI

-(void)configureNoFollowers {
    
//    UIImageView *frog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frog"]];
//    frog.frame = CGRectMake(self.view.frame.size.width/2 - 200/2, self.view.frame.size.height/2 -60, 200, 120);
//    frog.alpha = 0.54;
//    [self.followingTable addSubview:frog];
//    
//    UILabel *awkward = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2 +100, self.followingTable.frame.size.width, 30)];
//    [awkward setTextAlignment:NSTextAlignmentCenter];
//    [awkward setText:@"AWKWARD"];
//    [awkward setTextColor:[UIColor frescoDarkTextColor]];
//    [awkward setFont:[UIFont notaBoldWithSize:35]];
//    [self.followingTable addSubview:awkward];
//    
//    
//    UIView *textContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2 +140, self.followingTable.frame.size.width, 40)];
//    [self.followingTable addSubview:textContainer];
//    
//    UILabel *subText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.followingTable.frame.size.width, 40)];
//    [subText setTextAlignment:NSTextAlignmentCenter];
//    subText.backgroundColor = [UIColor clearColor];
//    [subText setText:@"It looks like you aren't following anyone yet. \nSee which of your friends are using Fresco         ."];
//    subText.numberOfLines = 2;
//    subText.textColor = [UIColor frescoMediumTextColor];
//    [subText setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]];
//    [subText sizeToFit];
//    subText.frame = CGRectMake(textContainer.frame.size.width/2 -subText.frame.size.width/2, subText.frame.origin.y, subText.frame.size.width, subText.frame.size.height);
//    [textContainer addSubview:subText];
//    
//    UIButton *here = [UIButton buttonWithType:UIButtonTypeSystem];
//    here.frame = CGRectMake(subText.frame.size.width - 18, 16, 40, 20);
//    [here setTitle:@"here" forState:UIControlStateNormal];
//    [here setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
//    [here.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
//    [here addTarget:self action:@selector(hereTapped) forControlEvents:UIControlEventTouchUpInside];
//    [textContainer addSubview:here];
}

-(void)hereTapped {
    NSLog(@"here");
}

-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    //Doesn't do anything
    //self.loadingView.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

-(void)configurePullToRefresh {
    loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
        [weakSelf reloadData];
    } loadingView:loadingView];
    
    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (needsUpdate) {
        needsUpdate = FALSE;
       // [self.tableView reloadData];
    }
    
    if (scrollView == self.pageScroller) {

    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (needsUpdate) {
        needsUpdate = FALSE;
       // [self.tableView reloadData];
    }
}

-(void)dealloc {
    [self.tableView dg_removePullToRefresh];
}

-(void)configureNavigationBar {
    
    [self removeNavigationBarLine];

    int offset = 8;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;

    NSLog(@"View Width/2: %f", self.view.frame.size.width/2);
    NSLog(@"Origin: %f", (self.tableView.frame.size.width/4));
    self.highlightTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 10 - titleView.frame.size.width/6, 6, 120, 30)];
    [self.highlightTabButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [self.highlightTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.highlightTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.highlightTabButton addTarget:self action:@selector(handleHighlightsTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.highlightTabButton];
    
    self.followingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 10 + titleView.frame.size.width/6, 6, 120, 30)];
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
        
    UIButton *sudoHighlightButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 10 - titleView.frame.size.width/6, 6, 120, 30)];
    [sudoHighlightButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [sudoHighlightButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [sudoHighlightButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.sudoNavBar addSubview:sudoHighlightButton];
    
    UIButton *sudoFollowingButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 10 + titleView.frame.size.width/6, 6, 120, 30)];
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

-(void)configureTableView {
    [super configureTableView];
    
//    self.tableView.backgroundColor = [UIColor frescoOrangeColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    self.tableView.frame = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height+20);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = YES;
    self.pageScroller.delegate = self;
    [self.view addSubview:self.pageScroller];
}

-(void)configureDataSource {
    
    // make core data fetch
    [self fetchLocalData];
    
    // network call
    [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:Nil completion:^(NSArray *galleries, NSError *error) {
        if ([galleries count] == 0){
            
        }
        else {
            [self cacheLocalData:galleries];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopLoading];
            [self.loadingView removeFromSuperview];
            hasLoadedOnce = TRUE;
        });
    }];
}

-(void)fetchLocalData {
    [self flushCache:Nil];

}

-(NSInteger)galleryExists:(NSString *)galleryID {
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

-(void)cacheLocalData:(NSArray *)localData {
    
    self.dataSource = [[NSMutableArray alloc] init];
    self.highlights = [[NSMutableArray alloc] init];

    NSInteger localIndex = 0;
    for (NSDictionary *gallery in localData) {
        FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[self.appDelegate managedObjectContext]];
        
        [galleryToSave configureWithDictionary:gallery context:[self.appDelegate managedObjectContext]];
        [galleryToSave setValue:[NSNumber numberWithInteger:localIndex] forKey:@"index"];
        [self.dataSource addObject:galleryToSave];
        [self.highlights addObject:galleryToSave];
        localIndex++;
    }
    
    [self.appDelegate.managedObjectContext save:Nil];
    [self.appDelegate saveContext];
    
    [self.tableView reloadData];
    
    for (FRSGallery *gallery in self.cachedData) {
        [self.appDelegate.managedObjectContext deleteObject:gallery];
    }
}

-(void)reloadFromLocal {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (shouldAnimate) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView reloadData];
        }
    });
}

-(void)flushCache:(NSArray *)received
{
    NSManagedObjectContext *moc = [self.appDelegate managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSGallery"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE]];
    
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    
    pulledFromCache = stored;
    
    self.dataSource = [NSMutableArray arrayWithArray:stored];
    self.highlights = self.dataSource;
    
    if ([_dataSource count] > 0) {
        [self.loadingView stopLoading];
        [self.loadingView removeFromSuperview];
    }
    else {
        if ([self.dataSource count] == 0){
            [self configureSpinner];
        }
    }
    
    self.cachedData = [NSMutableArray arrayWithArray:stored];
    [self.tableView reloadData];
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        return (self.dataSource.count == 0 || _loadNoMore) ? self.dataSource.count : self.dataSource.count + 1;
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        return [self heightForItemAtDataSourceIndex:indexPath.row];
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView && indexPath) {
        return [self highlightCellForIndexPath:indexPath];
    }

    return Nil;
}

-(UITableViewCell *)highlightCellForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.dataSource.count && self.dataSource.count != 0 && self.dataSource != Nil) { // we're reloading
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = 20;
        cell.frame = cellFrame;
        return cell;
    }
    
    FRSGalleryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
    
    if (!cell) {
        cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.navigationController = self.navigationController;
    }
    
    cell.gallery = self.dataSource[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell clearCell];
        [cell configureCell];
    });
    
    __weak typeof(self) weakSelf = self;
    
    cell.shareBlock = ^void(NSArray *sharedContent) {
        [weakSelf showShareSheetWithContent:sharedContent];
    };
    
    cell.readMoreBlock = ^(NSArray *bullshit){
        [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
    };
    
    cell.delegate = self;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;

}

-(void)loadMore {
    
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
        NSLog(@"NOT RELOADING");
        return;
    }
        
    lastOffset = self.dataSource.count;
    
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:offsetID completion:^(NSArray *galleries, NSError *error) {
                        
            if ([galleries count] == 0){
                _loadNoMore = TRUE;
                [self.tableView reloadData];
                return;
            }
            
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSInteger index = self.highlights.count;
            for (NSDictionary *gallery in galleries) {
                FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[self.appDelegate managedObjectContext]];
                
                [galleryToSave configureWithDictionary:gallery context:[self.appDelegate managedObjectContext]];
                [galleryToSave setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
                [self.dataSource addObject:galleryToSave];
                [self.highlights addObject:galleryToSave];
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0]];
                index++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                needsUpdate = TRUE;
                isLoading = FALSE;
            });
        });
    }];
}

-(void)playerWillPlay:(AVPlayer *)play {
    for (UITableView *tableView in @[self.tableView, self.followingTable]) {
        NSArray *visibleCells = [tableView visibleCells];
        for (FRSGalleryCell *cell in visibleCells) {
            if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]] || !cell.galleryView.players) {
                continue;
            }
            for (FRSPlayer *player in cell.galleryView.players) {
                if (player != play && [[player class] isSubclassOfClass:[FRSPlayer class]]) {
                    [player pause];
                }
            }
        }
    }
}

-(NSInteger)heightForItemAtDataSourceIndex:(NSInteger)index{
    
    if (index == self.dataSource.count) {
        return 20;
    }
    
    FRSGallery *gallery = self.dataSource[index];
//    return [self heightForCellForGallery:gallery];
    return [gallery heightForGallery];
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.row == self.dataSource.count-4) {
            if (!isLoading && !_loadNoMore) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self loadMore];
                });
            }
        }
    }
}


-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)storyClicked:(FRSStory *)story {
    
}
-(void)galleryClicked:(FRSGallery *)gallery {
    
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    vc.shouldHaveBackButton = YES;
    [super showNavBarForScrollView:self.tableView animated:NO];
    
    self.navigationItem.title = @"";
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];

}

-(void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)notification {
    
    FRSGallery *gallery = self.dataSource[notification.row];
    
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    vc.shouldHaveBackButton = YES;
    [super showNavBarForScrollView:self.tableView animated:NO];
    
    self.navigationItem.title = @"";
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];
}

#pragma mark - Nav Bar Actions

-(void)handleFollowingTabTapped {
    if (self.followingTabButton.alpha > 0.7) {
        return; //The button is already selected
    }
    
    [self.pageScroller setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
    
    self.followingTabButton.alpha = 1.0;
    self.highlightTabButton.alpha = 0.7;
}

-(void)handleHighlightsTabTapped {
    if (self.highlightTabButton.alpha > 0.7) {
        return;
    }
    [self.pageScroller setContentOffset:CGPointMake(0, 0) animated:YES];
    
    self.highlightTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;
}

-(void)searchStories {
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - UIScrollViewDelegate


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //self.sudoNavBar.frame = CGRectMake(0, (scrollView.contentOffset.x/8.5)-88, self.view.frame.size.width, 44);

    // Check if horizontal scrollView to avoid issues with potentially conflicting scrollViews
    
    //Make the nav bar expand relative to the x offset
    
    NSMutableArray *barButtonItems = [NSMutableArray array];
    [barButtonItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [barButtonItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    float navBarHeight=20.0;
    float scrollingDifference = (scrollView.contentOffset.x/self.tableView.frame.size.width*(navBarHeight*2))-navBarHeight-3;
    
    if(scrollView.contentOffset.x>0&&scrollView.contentOffset.x<self.tableView.frame.size.width && self.navigationController.navigationBar.frame.origin.y != navBarHeight){
        self.scrollDirection = UIAccessibilityScrollDirectionDown;
        [self expandNavBarBy:scrollingDifference BarButtonItems:barButtonItems];
    }
    
    NSLog(@"TABLEVIEW WIDTH: %f",self.tableView.frame.size.width);
    NSLog(@"CONTENT X: %f",scrollView.contentOffset.x);
    NSLog(@"SCROLLING Y: %f",scrollingDifference);

    if (scrollView == self.pageScroller) {
        
        self.loadingView.alpha = 1-(scrollView.contentOffset.x/(scrollView.contentSize.width - scrollView.frame.size.width));
        
        [self pausePlayers];
        if (self.pageScroller.contentOffset.x == self.view.frame.size.width) { // User is in right tab (following)
            self.followingTabButton.alpha = 1;
            self.highlightTabButton.alpha = 0.7;
            
            //[self showNavBarForScrollView:self.scrollView animated:NO];
            //self.navigationItem.titleView.alpha = 1;
            [self.tableView dg_stopLoading];
            [self.followingTable dg_stopLoading];

            [self.tableView dg_removePullToRefresh];
            loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            loadingView.tintColor = [UIColor whiteColor];

            __weak typeof(self) weakSelf = self;
            [self.followingTable dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
                [weakSelf reloadData];
            } loadingView:loadingView];
            
            [self.followingTable dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
            [self.followingTable dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }
        
        if (self.pageScroller.contentOffset.x == 0) { // User is in left tab (highlights)
            self.isInHighlights = true;
            self.isInFollowers = false;
            self.followingTabButton.alpha = 0.7;
            self.highlightTabButton.alpha = 1;
            [self.tableView dg_stopLoading];
            [self.followingTable dg_stopLoading];

            [self.followingTable dg_removePullToRefresh];
            
            loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
            loadingView.tintColor = [UIColor whiteColor];

            __weak typeof(self) weakSelf = self;
            [self.tableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
                [weakSelf reloadData];
            } loadingView:loadingView];
            
            [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
            [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
        }else if(self.pageScroller.contentOffset.x == self.tableView.frame.size.width){
            self.isInHighlights = false;
            self.isInFollowers = true;
        }

    }
    else {
        [super scrollViewDidScroll:scrollView];
    }
    
    if (scrollView == self.tableView) {
        NSArray *visibleCells = [self.tableView visibleCells];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL taken = FALSE;
            
            for (FRSGalleryCell *cell in visibleCells) {
                
                if (cell.frame.origin.y - self.tableView.contentOffset.y < 300 && cell.frame.origin.y - self.tableView.contentOffset.y > 100) {
                    
                    if (!taken) {
                        [cell play];
                        taken = TRUE;
                    }
                    else {
                        [cell pause];
                    }
                }
            }
        });
    }
    
    if (scrollView == self.pageScroller) {
        // animate nav up
        
    }
}

-(void)pausePlayers {
    for (UITableView *tableView in @[self.tableView, self.followingTable]) {
        for (FRSGalleryCell *cell in [tableView visibleCells]) {
            if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
                continue;
            }
            for (FRSPlayer *player in cell.galleryView.players) {
                if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
                    [player pause];
                }
            }
        }
    }
}

@end
