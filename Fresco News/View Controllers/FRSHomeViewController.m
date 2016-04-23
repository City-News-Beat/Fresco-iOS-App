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
    
    self.scrollView.delegate = self;
}

-(void)configureFollowing {
    CGRect scrollFrame = self.tableView.frame;
    scrollFrame.origin.x = scrollFrame.size.width;
    scrollFrame.origin.y = -64;
    
    self.followingTable = [[FRSFollowingTable alloc] initWithFrame:scrollFrame];
    [self.pageScroller addSubview:self.followingTable];
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
    
    
    
//    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
//    layer.frame = view.bounds;
//    layer.fillColor = [[UIColor blackColor] CGColor];
//    
//    layer.path = CGPathCreateWithRect(CGRectMake(10, 10, 30, 30), NULL);
//    
//    view.layer.mask = layer;
    
//    self.maskView = [[CAShapeLayer alloc] init];
//    self.maskView.frame = titleView.bounds;
//    self.maskView.fillColor = [UIColor redColor].CGColor;
//    self.maskView.path = CGPathCreateWithRect(CGRectMake(0, 0, 300, 20), nil);
//    self.highlightTabButton.layer.mask = self.maskView;
    
//    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
//    self.maskView.backgroundColor = [UIColor redColor];
//    self.maskView.maskView = self.highlightTabButton.titleLabel;
//    [titleView addSubview:self.maskView];
    
//    [UIView animateWithDuration:1.0 delay:5 options: UIViewAnimationOptionCurveEaseInOut animations:^{
//        
//        self.maskView.frame = CGRectMake(100, 0, 300, 20);
//
//    } completion:nil];
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
    [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:0 completion:^(NSArray *galleries, NSError *error) {
        if ([galleries count] == 0){
            return;
        }
        
        [self cacheLocalData:galleries];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopLoading];
            [self.loadingView removeFromSuperview];
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
    
    [self.tableView reloadData];
    
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
    
    if (tableView == self.tableView) {
        return (self.dataSource.count == 0) ? 0 : self.dataSource.count + 1;
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
    
    if (indexPath.row == self.dataSource.count-4) {
        if (!isLoading) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self loadMore];
            });
        }
    }
    
    cell.delegate = self;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
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
    
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:self.dataSource.count completion:^(NSArray *galleries, NSError *error) {
                        
            if ([galleries count] == 0){
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
        for (FRSGalleryCell *cell in [tableView visibleCells]) {
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

//-(NSInteger)heightForCellForGallery:(FRSGallery *)gallery{
//    
//    NSInteger totalHeight = 0;
//    
//    for (FRSPost *post in gallery.posts){
//        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
//        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];
//        
//        if (rawHeight == 0 || rawWidth == 0){
//            totalHeight += [UIScreen mainScreen].bounds.size.width;
//        }
//        else {
//            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width/rawWidth);
//            totalHeight += scaledHeight;
//        }
//    }
//    
//    NSInteger averageHeight = totalHeight/gallery.posts.count;
//    
//    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4/3);
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 32, 0)];
//
//    label.font = [UIFont systemFontOfSize:15 weight:-1];
//    label.text = gallery.caption;
//    label.numberOfLines = 6;
//
//    [label sizeToFit];
//    
//    averageHeight += label.frame.size.height + 12 + 44 + 20;
//    
//    return averageHeight;
//}




#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
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
    
    NSLog(@"self.pageScroller.contentOFfset.x = %f", self.pageScroller.contentOffset.x);
    
    // Check if horizontal scrollView to avoid issues with potentially conflicting scrollViews
    if (scrollView == self.pageScroller) {
        [self pausePlayers];
        if (self.pageScroller.contentOffset.x == self.view.frame.size.width) { // User is in right tab (following)
            self.followingTabButton.alpha = 1;
            self.highlightTabButton.alpha = 0.7;
            
            [self showNavBarForScrollView:self.scrollView animated:NO];
            self.navigationItem.titleView.alpha = 1;
        }
        
        if (self.pageScroller.contentOffset.x == 0) { // User is in left tab (highlights)
            self.followingTabButton.alpha = 0.7;
            self.highlightTabButton.alpha = 1;
            
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
            for (FRSPlayer *player in cell.galleryView.players) {
                if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
                    [player pause];
                }
            }
        }
    }
}

@end
