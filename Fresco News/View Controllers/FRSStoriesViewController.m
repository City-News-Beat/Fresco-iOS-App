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

#import "MagicalRecord.h"

#import "DGElasticPullToRefresh.h"
#import "FRSLoadingTableViewCell.h"
#import "FRSAppDelegate.h"

@interface FRSStoriesViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *stories;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) FRSAppDelegate *appDelegate;
@property (nonatomic) BOOL firstTime;
@property (nonatomic, retain) NSArray *cached;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) NSArray *cachedData;
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
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [self configureUI];
    [self fetchStories];
    
    if ([self.stories count] == 0){
        [self configureSpinner];
    }
}


#pragma mark - Configure UI

-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configurePullToRefresh];
//    [self configureSpinner];
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

    self.navigationItem.titleView.alpha = 1;
    
    if (!self.firstTime) {
        [self fetchStories];
    }
    
    self.firstTime = TRUE;
    
    id presentingViewController = self.presentingViewController;
    if ([presentingViewController isKindOfClass:[FRSStoryDetailViewController class]]) {
        self.tableView.frame = CGRectMake(0, -64, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    
    self.tableView.frame = CGRectMake(0, -64-44-20, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height+20);
    entry = [NSDate date];
    numberRead = 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 125)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 125;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (entry) {
        exit = [NSDate date];
        NSInteger sessionLength = [exit timeIntervalSinceDate:entry];
        [FRSTracker track:@"Stories session" parameters:@{activityDuration:@(sessionLength), @"count":@(numberRead)}];
    }

    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark -  UI

-(void)configureNavigationBar {
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationItem.titleView.frame.size.width/2 - 44, 6, 75, 30)];
    label.text = @"STORIES";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self.navigationItem.titleView addSubview:label];
}

-(void)configurePullToRefresh {
    [super removeNavigationBarLine];
    
    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor frescoBlueColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:0 actionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf reloadData];
        });
    } loadingView:loadingView];
    
    [self.tableView dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}

-(void)reloadData {
    [[FRSAPIClient new] fetchStoriesWithLimit:self.stories.count lastStoryID:Nil completion:^(NSArray *stories, NSError *error) {
        
        if ([stories count] == 0 || error){
            _loadNoMore = TRUE;
            [self.tableView reloadData];
            return;
        }
        self.stories = [[NSMutableArray alloc] init];

        [self cacheLocalData:stories];
        
        
        NSInteger index = 0;
        
        for (NSDictionary *storyDict in stories){
            FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:self.appDelegate.managedObjectContext];
            
            [story configureWithDictionary:storyDict];
            [story setValue:@(index) forKey:@"index"];
            [self.stories addObject:story];
            index++;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView dg_stopLoading];
            [self.tableView reloadData];
            [self.appDelegate.managedObjectContext save:Nil];
            [self.appDelegate saveContext];
        });
    }];

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
     //   [self fetchLocalData];
        [self.tableView reloadData];
        __block int const numToFetch = 12;
        
        [[FRSAPIClient new] fetchStoriesWithLimit:numToFetch lastStoryID:Nil completion:^(NSArray *stories, NSError *error) {
            self.stories = [[NSMutableArray alloc] init];
            
            if ([stories count] == 0){
                _loadNoMore = TRUE;
                [self.tableView reloadData];
                return;
            }

            [self cacheLocalData:stories];
            
            NSInteger index = 0;
            
            for (NSDictionary *storyDict in stories){
                
                [self.loadingView stopLoading];
                [self.loadingView removeFromSuperview];
                
                FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:self.appDelegate.managedObjectContext];
                
                [story configureWithDictionary:storyDict];
                [story setValue:@(index) forKey:@"index"];
                [self.stories addObject:story];
                index++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.appDelegate.managedObjectContext save:Nil];
                [self.appDelegate saveContext];
            });
        }];
}

-(void)fetchMoreStories {
    
    if (_loadNoMore) {
        return;
    }
    
    if (!self.stories) {
        self.stories = [[NSMutableArray alloc] init];
    }
    __block int const numToFetch = 12;
    NSString *offsetID = @"";
    
    if (self.stories.count > 0) {
        FRSStory *lastStory = self.stories[self.stories.count-1];
        offsetID = lastStory.uid;
    }
    
    [[FRSAPIClient new] fetchStoriesWithLimit:numToFetch lastStoryID:offsetID completion:^(NSArray *stories, NSError *error) {
        
        if (!stories.count){
            if (error) {
                NSLog(@"Error fetching stories %@", error.localizedDescription);
            }
            else {
                _loadNoMore = TRUE;
               NSLog(@"No error fetching stories but the request returned zero results");
            }
        }
        
        NSLog(@"%@", stories);
        
        if (stories.count < numToFetch || stories.count == 0) {
            _loadNoMore = TRUE;
        }
        
        if (stories.count == 0) {
            [self.tableView reloadData];
            return;
        }
        
        NSInteger index = self.stories.count;
        NSMutableArray *storiesToLoad = [[NSMutableArray alloc] init];
        for (NSDictionary *storyDict in stories){
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"FRSStory" inManagedObjectContext:self.appDelegate.managedObjectContext];
            FRSStory *story = (FRSStory *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
            [story configureWithDictionary:storyDict];
            [story setValue:@(self.stories.count) forKey:@"index"];
            [self.stories addObject:story];
            [storiesToLoad addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            index++;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }];
}

-(void)fetchLocalData {
    NSManagedObjectContext *moc = [self.appDelegate managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSStory"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE]];
    
    NSError *error = nil;
    self.stories = [NSMutableArray arrayWithArray:[moc executeFetchRequest:request error:&error]];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    self.cached = self.stories;
}

-(void)cacheLocalData:(NSArray *)localData {
    for (FRSStory *story in self.cached) {
        [self.appDelegate.managedObjectContext deleteObject:story];
    }
    
    [self.appDelegate.managedObjectContext save:Nil];
    [self.appDelegate saveContext];
}

-(FRSStory *)storyExists:(NSString *)storyID {
    
    for (FRSStory *story in self.stories) {
        if ([story.uid isEqualToString:storyID]) {
            return story;
        }
    }
    
    return Nil;
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_loadNoMore) {
        return self.stories.count;
    }
    
    return (self.stories.count == 0) ? 0 : self.stories.count+1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.stories.count) {
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
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = 20;
        cell.frame = cellFrame;
        return cell;
    }
    
    if (indexPath.row > numberRead) {
        numberRead = indexPath.row;
    }
    
    FRSStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
    
    if (!cell){
        cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == self.stories.count - 5 || (indexPath.row == self.stories.count && self.stories.count < 4)) {
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
    
    [cell clearCell];
    
    if (indexPath.row < self.stories.count) {
        
        __weak typeof(self) weakSelf = self;
        cell.story = self.stories[indexPath.row];
        
        cell.actionBlock = ^{
            [weakSelf readMore:indexPath.row];
        };
        
        cell.shareBlock = ^void(NSArray *sharedContent) {
            [weakSelf showShareSheetWithContent:sharedContent];
        };
        
        cell.imageBlock = ^(NSInteger imageIndex){
            [weakSelf handleImagePress:indexPath imageIndex:imageIndex];
        };
        
        [cell configureCell];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!firstOpen) {
        firstOpen = TRUE;
    }
    else {
        [self reloadData];
    }
}
-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

-(void)handleImagePress:(NSIndexPath *)cellIndex imageIndex:(NSInteger)imageIndex {
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:[self.stories objectAtIndex:cellIndex.row]];
    detailView.navigationController = self.navigationController;
    [detailView scrollToGalleryIndex:imageIndex];
    [self.navigationController pushViewController:detailView animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    self.navigationItem.rightBarButtonItem.customView.alpha = 0;
}

-(void)readMore:(NSInteger)index {
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:[self.stories objectAtIndex:index]];
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
}

@end
