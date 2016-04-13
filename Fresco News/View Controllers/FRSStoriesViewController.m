//
//  FRSStoriesViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "Fresco.h"

#import "FRSStoriesViewController.h"
#import "FRSSearchViewController.h"

#import "FRSStoryCell.h"

#import "FRSStory.h"

#import <MagicalRecord/MagicalRecord.h>

#import "DGElasticPullToRefresh.h"
#import "FRSLoadingTableViewCell.h"

@interface FRSStoriesViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *stories;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL firstTime;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@end

@implementation FRSStoriesViewController

-(void)dealloc {
    [self.tableView dg_removePullToRefresh];
}

-(instancetype)init {
    self = [super init];
    if (self){
        self.firstTime = YES;
    }
    return self;
}

-(FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self fetchStories];
}


#pragma mark - Configure UI

-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configurePullToRefresh];
    [self configureSpinner];
    [self configureNavigationBar];
}

//-(void)configureSpinner {
//    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self.spinner setCenter: CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 44)];
//    [self.view addSubview:self.spinner];
//    
//    [self.spinner startAnimating];
//}

-(void)configureSpinner {
    
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.firstTime) {
        [self fetchStories];   
    }
    
    self.firstTime = TRUE;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -  UI

-(void)configureNavigationBar {
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"STORIES";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self.navigationItem setTitleView:label];
}

-(void)configurePullToRefresh {
    [super removeNavigationBarLine];
    
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

-(void)configureTableView {
    [super configureTableView];
    
    // loading cell
//    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


#pragma mark - Search Methods
-(void)searchStories {
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}


#pragma mark - Fetch Methods

-(void)fetchStories {
    [self fetchLocalData];
    __block int const numToFetch = 12;

    [[FRSAPIClient new] fetchStoriesWithLimit:numToFetch lastStoryID:0 completion:^(NSArray *stories, NSError *error) {
        self.stories = [[NSMutableArray alloc] init];
        
        if (!stories.count){
            if (error) NSLog(@"Error fetching stories %@", error.localizedDescription);
            else NSLog(@"No error fetching stories but the request returned zero results");
            return;
        }
        
        [self cacheLocalData:stories];

            for (NSDictionary *storyDict in stories){
                FRSStory *story; 
                
//                [self.spinner stopAnimating];
                [self.loadingView stopLoading];
                [self.loadingView removeFromSuperview];
                
                if (!story) {
                    story = [FRSStory MR_createEntity];
                    [story configureWithDictionary:storyDict];
                    [self.stories addObject:story];
                }
                else {
                    [self.stories addObject:story];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
    }];
}

-(void)fetchMoreStories {

    if (!self.stories) {
        self.stories = [[NSMutableArray alloc] init];
    }
    __block int const numToFetch = 12;
    
    [[FRSAPIClient new] fetchStoriesWithLimit:numToFetch lastStoryID:self.stories.count completion:^(NSArray *stories, NSError *error) {
        
        if (!stories.count){
            if (error) NSLog(@"Error fetching stories %@", error.localizedDescription);
            else NSLog(@"No error fetching stories but the request returned zero results");
            return;
        }
        
        for (NSDictionary *storyDict in stories){
            FRSStory *story = [FRSStory MR_findFirstByAttribute:@"uid" withValue:storyDict[@"_id"]];
           // NSMutableArray *storiesToLoad = [[NSMutableArray alloc] init];
            
            NSInteger index = self.stories.count;
            
            if (!story) {
                story = [FRSStory MR_createEntity];
                [story configureWithDictionary:storyDict];
                [self.stories addObject:story];
                //[storiesToLoad addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                index++;
            }
            else {
                [self.stories addObject:story];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
               /* [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:storiesToLoad withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates]; */
                [self.tableView reloadData];
            });
        }
    }];
}

-(void)fetchLocalData {
    NSArray *stories = [FRSStory MR_findAllSortedBy:@"index" ascending:YES];
    self.stories = [stories mutableCopy];
    [self.tableView reloadData];
}

-(void)cacheLocalData:(NSArray *)localData {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NSDictionary *story in localData) {
            NSString *storyID = [story objectForKey:@"_id"];
            
            if ([self storyExists:storyID]) {
                continue;
            }
            
            FRSStory *storySave = [FRSStory MR_createEntityInContext:localContext];
            [storySave configureWithDictionary:story];
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {

        [self flushCache:localData]; // empty non-remote stories (oos)
    }];
}

-(BOOL)storyExists:(NSString *)storyID {
    
    for (FRSStory *story in self.stories) {
        if ([story.uid isEqualToString:storyID]) {
            return TRUE;
        }
    }
    
    return FALSE;
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.stories.count == 0) ? 0 : self.stories.count+1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.stories.count-1) {
        return 20;
    }
    
    if (!self.stories.count) {
        return 0;
    }
    
    if (indexPath.row >= self.stories.count) {
        return 20;
    }
    
    FRSStory *story = self.stories[indexPath.row];
    return [story heightForStory];
}

-(void)flushCache:(NSArray *)nonLocalData {
    //
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // if we're loading more data
    if (indexPath.row == self.stories.count -1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    FRSStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
    
    if (!cell){
        cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == self.stories.count - 5) {
        [self fetchMoreStories];
    }
    
    return cell;
}

#pragma mark UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSStoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![[cell class] isSubclassOfClass:[FRSStoryCell class]]) {
        return;
    }
    
    // POSSIBLE BUG!!
    if (self.stories.count > indexPath.row && cell.story == self.stories[indexPath.row]) {
        return;
    }
    
    [cell clearCell];
    
    if (indexPath.row < self.stories.count) {
        
        __weak typeof(self) weakSelf = self;
        cell.story = self.stories[indexPath.row];
        
        cell.actionBlock = ^{
            [weakSelf readMore:indexPath.row];
        };
        
        [cell configureCell];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    
    self.navigationItem.rightBarButtonItem.customView.alpha = 0;
    NSLog(@"contentOffset.y = %f", scrollView.contentOffset.y);

}

-(void)readMore:(NSInteger)index {
    NSLog(@"READ MORE: %lu", (long)index);
    
//    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
//    }
    
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:[self.stories objectAtIndex:index]];
    [self.navigationController pushViewController:detailView animated:YES];
}

@end