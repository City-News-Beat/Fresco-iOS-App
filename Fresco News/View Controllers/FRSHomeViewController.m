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

/* Core Data */
#import <MagicalRecord/MagicalRecord.h>
#import "FRSCoreData.h"
#import "FRSAppDelegate.h"
#import "FRSGallery+CoreDataProperties.h"


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

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *pulled;
@property (weak, nonatomic) FRSAppDelegate *appDelegate;
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
    
    self.scrollView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
    [self addStatusBarNotification];
    [self showNavBarForScrollView:self.scrollView animated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTabBarAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self removeStatusBarNotification];
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

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    FRSGalleryCell *galleryCell = (FRSGalleryCell *)cell;
    if ([galleryCell respondsToSelector:@selector(pause)]) {
        [galleryCell pause];
    }
}


#pragma mark - UI

-(void)configureSpinner {
    
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

-(void)configurePullToRefresh {
    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView dg_stopLoading];
        });
    } loadingView:loadingView];
    
    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (needsUpdate) {
        needsUpdate = FALSE;
       // [self.tableView reloadData];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return;
    }
    
    NSArray *visibleCells = [[self.tableView visibleCells] mutableCopy];
    visibleCells = [visibleCells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES]]];
    
    float openY = scrollView.contentOffset.y;
    BOOL foundPlayer = FALSE;
    
    for (FRSGalleryCell *cell in visibleCells) {
        float cellY = cell.frame.origin.y - openY;
        if (!foundPlayer && cellY < 450 && [cell player].rate == 0.0 && [[cell player] respondsToSelector:@selector(play)] && ![cell player].playWhenReady && [[cell player] hasPlayed] == FALSE) {
            cell.hasAlreadyAutoPlayed = TRUE;
            [cell play];
            cell.isCurrentPlayer = TRUE;
            foundPlayer = TRUE;
        }
        else {
            cell.isCurrentPlayer = FALSE;
        }
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

    self.highlightTabButton = [[UIButton alloc] initWithFrame:CGRectMake(80.7, 12, 87, 20)];
    [self.highlightTabButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [self.highlightTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.highlightTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.highlightTabButton addTarget:self action:@selector(handleHighlightsTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.highlightTabButton];
    
    self.followingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(208.3, 12, 87, 20)];
    self.followingTabButton.alpha = 0.7;
    [self.followingTabButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.followingTabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.followingTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followingTabButton addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.followingTabButton];
    
    if (IS_IPHONE_6) {
        self.highlightTabButton.frame = CGRectMake(80.7  - offset, 12, 87, 20);
        self.followingTabButton.frame  = CGRectMake(208.3 - offset, 12, 87, 20);
    } else if (IS_IPHONE_6_PLUS) {
        self.highlightTabButton.frame = CGRectMake(93.7  - offset, 12, 87, 20);
        self.followingTabButton.frame  = CGRectMake(234.3 - offset, 12, 87, 20);
    } else if (IS_IPHONE_5) {
        self.highlightTabButton.frame = CGRectMake(62.3  - offset, 12, 87, 20);
        self.followingTabButton.frame  = CGRectMake(171.7 - offset, 12, 87, 20);
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
      
}

-(void)configureTableView {
    [super configureTableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height +200);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
}

-(void)configureDataSource {
    
    // make core data fetch
    [self fetchLocalData];
    
    // network call
    [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:0 completion:^(NSArray *galleries, NSError *error) {
        if ([galleries count] == 0){
            return;
        }
        
        [self cacheLocalData:galleries];
        [self.loadingView stopLoading];
        [self.loadingView removeFromSuperview];
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
    NSArray *past;
    
    if (self.dataSource.count > 1) {
        past = @[[self.dataSource[0] uid],[self.dataSource[1] uid]];
    }
    
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
    
    if (self.dataSource.count > 1 && past) {
        if ([past[0] isEqualToString:[self.dataSource[0] uid]] && [past[1] isEqualToString:[self.dataSource[1] uid]]) {
            // no animate
            [self.tableView reloadData];
        }
        else {
            // animate
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    for (FRSGallery *gallery in self.cachedData) {
        [self.appDelegate.managedObjectContext deleteObject:gallery];
    }
    
    [self.appDelegate.managedObjectContext save:Nil];
    [self.appDelegate saveContext];
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
    return (self.dataSource.count == 0) ? 0 : self.dataSource.count + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForItemAtDataSourceIndex:indexPath.row];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.dataSource.count && self.dataSource.count != 0 && self.dataSource != Nil) { // we're reloading
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    FRSGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
    
    if (!cell) {
        cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.navigationController = self.navigationController;
    }
    
    if (indexPath.row == self.dataSource.count-4) {
        if (!isLoading) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self loadMore];
            });
        }
    }
    cell.row = @(indexPath.row);
    cell.delegate = self;
    cell.hasAlreadyAutoPlayed = FALSE;
    return cell;
}

-(void)loadMore {
    
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
    
    NSLog(@"RELOADING WITH OFFSET ID: %@", offsetID);
    
    lastOffset = self.dataSource.count;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:self.dataSource.count completion:^(NSArray *galleries, NSError *error) {
                        
            if ([galleries count] == 0){
                return;
            }
            
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
        }];
    });
}

-(void)playerWillPlay:(AVPlayer *)player {
    for (FRSGalleryCell *cell in [self.tableView visibleCells]) {
        if (cell.isCurrentPlayer)
            continue;
        for (FRSPlayer *player in cell.galleryView.players) {
            if ([player respondsToSelector:@selector(rate)] && player.rate != 0.0) {
                [player pause];
            }
        }
    }
}

-(NSInteger)heightForItemAtDataSourceIndex:(NSInteger)index{
    if (index == self.dataSource.count) {
        return 40;
    }
    
    FRSGallery *gallery = self.dataSource[index];
//    return [self heightForCellForGallery:gallery];
    return [gallery heightForGallery];
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }

    if (self.cachedData.count > indexPath.row) {
        NSString *oldUID = [self.cachedData[indexPath.row] uid];
        NSString *newUID = [self.dataSource[indexPath.row] uid];
        
        if ([oldUID isEqualToString:newUID] && self.cachedData[indexPath.row] != self.dataSource[indexPath.row]) {
            return;
        }
    }
    cell.hasAlreadyAutoPlayed = FALSE;

    cell.gallery = self.dataSource[indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell clearCell];
        [cell configureCell];
    });
    
    __weak typeof(self) weakSelf = self;
    
    cell.shareBlock = ^void(NSArray *sharedContent) {
        [weakSelf showShareSheetWithContent:sharedContent];
    };
    
}


-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification {
    
    NSArray *filteredArray = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];
    
    if (!filteredArray.count) return;
    
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[filteredArray firstObject]];
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

    self.followingTabButton.alpha = 1.0;
    self.highlightTabButton.alpha = 0.7;
}

-(void)handleHighlightsTabTapped {
    if (self.highlightTabButton.alpha > 0.7) {
        return;
    }
    
    self.highlightTabButton.alpha = 1.0;
    self.followingTabButton.alpha = 0.7;
}

-(void)searchStories {
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}


@end
