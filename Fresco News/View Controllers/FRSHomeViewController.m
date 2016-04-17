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


@interface FRSHomeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL isLoading;
    NSInteger lastOffset;
}

@property (strong, nonatomic) NSMutableArray *highlights;
@property (strong, nonatomic) NSArray *followingGalleries;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIButton *highlightTabButton;
@property (strong, nonatomic) UIButton *followingTabButton;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) NSMutableArray *players;
@end

@implementation FRSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    if (indexPath.row == self.dataSource.count) {
        return;
    }
    
    FRSGalleryCell *galleryCell = (FRSGalleryCell *)cell;
    [galleryCell pause];
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

    UIButton *highlightsButton = [[UIButton alloc] initWithFrame:CGRectMake(80.7, 12, 87, 20)];
    [highlightsButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [highlightsButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [highlightsButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [highlightsButton addTarget:self action:@selector(handleHighlightsTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:highlightsButton];
    
    UIButton *followingButton = [[UIButton alloc] initWithFrame:CGRectMake(208.3, 12, 87, 20)];
    [followingButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [followingButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [followingButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [followingButton addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:followingButton];
    
    if (IS_IPHONE_6) {
        highlightsButton.frame = CGRectMake(80.7  - offset, 12, 87, 20);
        followingButton.frame  = CGRectMake(208.3 - offset, 12, 87, 20);
    } else if (IS_IPHONE_6_PLUS) {
        highlightsButton.frame = CGRectMake(93.7  - offset, 12, 87, 20);
        followingButton.frame  = CGRectMake(234.3 - offset, 12, 87, 20);
    } else if (IS_IPHONE_5) {
        highlightsButton.frame = CGRectMake(62.3  - offset, 12, 87, 20);
        followingButton.frame  = CGRectMake(171.7 - offset, 12, 87, 20);
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)configureTableView {
    [super configureTableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64- 49);
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
        [self.tableView reloadData];
    }];
}

-(void)fetchLocalData {
    NSArray *stored = [FRSGallery MR_findAllSortedBy:@"index" ascending:YES withPredicate:Nil];
    pulledFromCache = stored;
    
    _dataSource = [[NSMutableArray alloc] init];
    _highlights = [[NSMutableArray alloc] init];
    
    [_dataSource addObjectsFromArray:stored];
    [_highlights addObjectsFromArray:stored];
    
    if ([_dataSource count] > 0) {
        [self.tableView reloadData];
        [self.loadingView stopLoading];
        [self.loadingView removeFromSuperview];
    }
    else {
        if ([self.dataSource count] == 0){
            [self configureSpinner];
        }
    }
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
    
    if (!self.dataSource) {
        self.dataSource = [[NSMutableArray alloc] init];
        self.highlights = [[NSMutableArray alloc] init];
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        NSInteger localIndex = 0;
        
        for (NSDictionary *gallery in localData) {
            
            NSString *galleryID = [gallery objectForKey:@"_id"];
            
            NSInteger index = [self galleryExists:galleryID];
            
            if (index > -1) {
                continue;
            }
            
            FRSGallery *galleryToSave = [FRSGallery MR_createEntityInContext:localContext];
            [galleryToSave configureWithDictionary:gallery context:localContext];
            [galleryToSave setValue:@(localIndex) forKey:@"index"];
            localIndex++;
        }
        
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSLog(@"Cache: %d %@", contextDidSave, error);
        [self flushCache:localData];
    }];
    
    // actual use
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary *gallery in localData) {
        FRSGallery *use = [FRSGallery MR_createEntity];
        [use configureWithDictionary:gallery];
        [temp addObject:use];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.dataSource = [[NSMutableArray alloc] initWithArray:temp];
        self.highlights = [[NSMutableArray alloc] initWithArray:temp];
        
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

-(void)flushCache:(NSArray *)received {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        for (FRSGallery *gallery in pulledFromCache) {
            if (![self galleryExists:gallery.uid]) {
                [gallery MR_deleteEntityInContext:localContext];
            }
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSLog(@"Flush: %d %@", contextDidSave, error);
    }];
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
    }
    
    if (indexPath.row == self.dataSource.count-4) {
        if (!isLoading) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self loadMore];
            });
        }
    }
    
    return cell;
}

-(void)loadMore {
    
    isLoading = TRUE;
    FRSGallery *lastGallery = [self.dataSource lastObject];
    NSString *offsetID = lastGallery.uid;
    
    if (lastOffset == self.dataSource.count) {
        NSLog(@"NOT RELOADING");
        return;
    }
    
    NSLog(@"RELOADING WITH OFFSET ID: %@", offsetID);
    
    lastOffset = self.dataSource.count;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:self.dataSource.count completion:^(NSArray *galleries, NSError *error) {
                        
            if ([galleries count] == 0){
                return;
            }
            
            isLoading = FALSE;
            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
            NSInteger index = self.highlights.count;
            
            for (NSDictionary *dict in galleries){
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                FRSGallery *gallery = [FRSGallery MR_createEntity];
                [gallery configureWithDictionary:dict];
                
                [self.dataSource addObject:gallery];
                [self.highlights addObject:gallery];
                index++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                needsUpdate = TRUE;
            });
        }];
    });
}

-(void)playerWillPlay:(AVPlayer *)player {
    for (FRSGalleryCell *cell in [self.tableView visibleCells]) {
        if (cell.player && cell.player != player) {
            [cell.player pause];
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
    
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }

    if (cell.gallery == self.dataSource[indexPath.row]) {
        return;
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
    
}

-(void)handleHighlightsTabTapped {
    
}

-(void)searchStories {
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}


@end
