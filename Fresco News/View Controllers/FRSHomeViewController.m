//
//  FRSHomeViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSHomeViewController.h"

#import "FRSGalleryExpandedViewController.h"

#import "FRSGalleryCell.h"
#import "FRSDataManager.h"

#import "FRSTabbedNavigationTitleView.h"

#import <MagicalRecord/MagicalRecord.h>

#import "DGElasticPullToRefresh.h"

#import "Fresco.h"

@interface FRSHomeViewController () <UITableViewDataSource, UITableViewDelegate, FRSTabbedNavigationTitleViewDelegate>
{
    BOOL isLoading;
    NSInteger lastOffset;
}
@property (strong, nonatomic) NSMutableArray *highlights;
@property (strong, nonatomic) NSArray *followingGalleries;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIButton *highlightTabButton;
@property (strong, nonatomic) UIButton *followingTabButton;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property BOOL contentIsEmpty;

@end

@implementation FRSHomeViewController


-(UIImage *)imageForLeftBarItem {
    return Nil;
}

-(void)tabbedNavigationTitleViewDidTapRightBarItem {
    
}

-(void)tabbedNavigationTitleViewDidTapLeftBarItem {
    
}

-(void)tabbedNavigationTitleViewDidTapButtonAtIndex:(NSInteger)index {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self addNotificationObservers];
    
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
}

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureTableView];
    [self configureDataSource];
    [self configurePullToRefresh];
    
//    if (self.contentIsEmpty) {
        [self configureSpinner];
//    }
}

-(void)addNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];
}

#pragma mark - UI

-(void)configureSpinner{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner setCenter: CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 44)];
    [self.view addSubview:self.spinner];
    
    [self.spinner startAnimating];
}

-(void)configurePullToRefresh{
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

- (void)dealloc{
    [self.tableView dg_removePullToRefresh];
}

-(void)configureNavigationBar{
    
    [self removeNavigationBarLine];
    
    FRSNavigationController *frsNav = (FRSNavigationController *)self.navigationController;
    [frsNav configureFRSNavigationBarWithTabs:@[@"HIGHLIGHTS", @"FOLLOWING"]];
    
//    FRSTabbedNavigationTitleView *titleView = [[FRSTabbedNavigationTitleView alloc] initWithTabTitles:@[@"HIGHLIGHTS", @"FOLLOWING"] delegate:self hasBackButton:NO];
//    self.navigationController.navigationBar.topItem.titleView = titleView;
    
}

-(UIImage *)imageForRightBarItem{
    return [UIImage imageNamed:@"search-icon"];
}

-(void)configureTableView
{
    [super configureTableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64- 49);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // registering nib for bottom cell
    
    [self.view addSubview:self.tableView];
}

-(void)configureDataSource{
    
    // make core data fetch
    [self fetchLocalData];
    self.dataSource = [[NSMutableArray alloc] init];
    self.highlights = [[NSMutableArray alloc] init];
    
    // network call
    [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:0 completion:^(NSArray *galleries, NSError *error) {
        
        if ([galleries count] == 0){
            return;
        }
        
        
        [self.spinner stopAnimating];

        for (NSDictionary *dict in galleries){
            FRSGallery *gallery = [FRSGallery MR_createEntity];
            [gallery configureWithDictionary:dict];
            [self.dataSource addObject:gallery];
            [self.highlights addObject:gallery];
            [self.tableView reloadData];
            [self cacheLocalData];
        }
    }];
}

-(void)fetchLocalData {
    
}

-(void)cacheLocalData {
    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.dataSource.count == 0) ? 0 : self.dataSource.count + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    
    if (indexPath.row == self.dataSource.count - 5) {
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
    
    [[FRSAPIClient sharedClient] fetchGalleriesWithLimit:12 offsetGalleryID:self.dataSource.count completion:^(NSArray *galleries, NSError *error) {
        
        NSLog(@"RELOADING: %lu", galleries.count);
        
        if ([galleries count] == 0){
            return;
        }
        
        isLoading = FALSE;
        
        for (NSDictionary *dict in galleries){
            FRSGallery *gallery = [FRSGallery MR_createEntity];
            [gallery configureWithDictionary:dict];
            
            [self.dataSource addObject:gallery];
            [self.highlights addObject:gallery];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self cacheLocalData];
        });
        
    }];
}

-(NSInteger)heightForItemAtDataSourceIndex:(NSInteger)index{
    if (index == self.dataSource.count) {
        return 65;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }
    
    [cell clearCell];
    
    cell.gallery = self.dataSource[indexPath.row];
    [cell configureCell];
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
    [self hideTabBarAnimated:YES];
}

#pragma mark - Nav Bar Actions

-(void)handleFollowingTabTapped{
    
}

-(void)handleHighlightsTabTapped{
    
}

-(void)search {

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.y;
    if (offset <= 0) {
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(-offset, 0, 0, 0);
    }
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
