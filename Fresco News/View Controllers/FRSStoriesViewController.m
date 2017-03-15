

//
//  FRSStoriesViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoriesViewController.h"
#import "FRSSearchViewController.h"
#import "FRSStoryTableViewCell.h"
#import "FRSStory.h"
#import "MagicalRecord.h"
#import "DGElasticPullToRefresh.h"
#import "FRSLoadingTableViewCell.h"
#import "FRSDualUserListViewController.h"
#import "FRSStoryManager.h"

static NSInteger const storiesPerPage = 12;

@interface FRSStoriesViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FRSContentActionBarDelegate>

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

- (void)dealloc {
    [self.tableView dg_removePullToRefresh];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.firstTime = YES;
    }
    return self;
}

- (FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self configureUI];
    [self fetchStories];

    if ([self.stories count] == 0) {
        [self configureSpinner];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!firstOpen) {
        firstOpen = TRUE;
    } else {
        [self reloadData];
    }
}

#pragma mark - Configure UI

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configurePullToRefresh];
    [self configureNavigationBar];
}

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.navigationController setNavigationBarHidden:YES];

    [FRSTracker screen:@"Stories"];

    self.navigationItem.titleView.alpha = 1;

    if (!self.firstTime) {
        [self fetchStories];
    }

    self.firstTime = TRUE;

    id presentingViewController = self.presentingViewController;
    if ([presentingViewController isKindOfClass:[FRSStoryDetailViewController class]]) {
        self.tableView.frame = CGRectMake(0, -64, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    }

    self.tableView.frame = CGRectMake(0, -64 - 44 - 20, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height + 20 + 44);
    entry = [NSDate date];
    numberRead = 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 125)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 125;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (entry) {
        exit = [NSDate date];
        NSInteger sessionLength = [exit timeIntervalSinceDate:entry];
        [FRSTracker track:storiesSession
               parameters:@{ activityDuration : @(sessionLength),
                             @"stories_scrolled_past" : @(numberRead) }];
    }

    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark -  UI

- (void)configureNavigationBar {
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationItem.titleView.frame.size.width / 2 - 44, 6, 75, 30)];
    label.text = @"STORIES";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];

    [self.navigationItem.titleView addSubview:label];
}

- (void)configurePullToRefresh {
    [super removeNavigationBarLine];

    DGElasticPullToRefreshLoadingViewCircle *loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor frescoBlueColor];

    __weak typeof(self) weakSelf = self;

    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0
                                         minOffsetToPull:80
                                     loadingContentInset:44
                                         loadingViewSize:20
                                                velocity:0
                                           actionHandler:^{
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               [weakSelf reloadData];
                                             });
                                           }
                                             loadingView:loadingView
                                                    yPos:0];

    [self.tableView dg_setPullToRefreshFillColor:self.tableView.backgroundColor];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
}

- (void)reloadData {
    [[FRSStoryManager sharedInstance] fetchStoriesWithLimit:storiesPerPage
                                                lastStoryID:nil
                                                 completion:^(NSArray *stories, NSError *error) {
                                                   [self.tableView dg_stopLoading];
                                                   if (error) {
                                                       self.loadNoMore = YES;
                                                       return;
                                                   }
                                                   self.stories = [[NSMutableArray alloc] init];

                                                   [self cacheLocalData:stories];

                                                   NSInteger index = 0;

                                                   for (NSDictionary *storyDict in stories) {
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

- (void)configureTableView {
    [super configureTableView];

    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSStoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyCellIdentifier];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - Search Methods
- (void)searchStories {
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - Fetch Methods

- (void)fetchStories {
    [self.tableView reloadData];

    [[FRSStoryManager sharedInstance] fetchStoriesWithLimit:storiesPerPage
                                                lastStoryID:nil
                                                 completion:^(NSArray *stories, NSError *error) {
                                                   self.stories = [[NSMutableArray alloc] init];
                                                   [self.loadingView stopLoading];
                                                   [self.loadingView removeFromSuperview];

                                                   if ([stories count] == 0) {
                                                       self.loadNoMore = YES;
                                                       [self.tableView reloadData];
                                                       return;
                                                   }

                                                   [self cacheLocalData:stories];

                                                   NSInteger index = 0;
                                                   for (NSDictionary *storyDict in stories) {
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

- (void)fetchMoreStories {
    if (self.loadNoMore) {
        return;
    }

    if (!self.stories) {
        self.stories = [[NSMutableArray alloc] init];
    }
    NSString *offsetID = @"";

    if (self.stories.count > 0) {
        FRSStory *lastStory = self.stories[self.stories.count - 1];
        offsetID = lastStory.uid;
    }

    [[FRSStoryManager sharedInstance] fetchStoriesWithLimit:storiesPerPage
                                                lastStoryID:offsetID
                                                 completion:^(NSArray *stories, NSError *error) {
                                                   if (!stories.count) {
                                                       if (error) {
                                                           NSLog(@"Fetch Stories Error: %@", error.localizedDescription);
                                                       } else {
                                                           self.loadNoMore = YES;
                                                           NSLog(@"No error fetching stories but the request returned zero results");
                                                       }
                                                   }

                                                   if (stories.count < storiesPerPage || stories.count == 0) {
                                                       self.loadNoMore = YES;
                                                   }

                                                   if (stories.count == 0) {
                                                       [self.tableView reloadData];
                                                       return;
                                                   }

                                                   NSInteger index = self.stories.count;
                                                   NSMutableArray *storiesToLoad = [[NSMutableArray alloc] init];
                                                   for (NSDictionary *storyDict in stories) {
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

- (void)fetchLocalData {
    NSManagedObjectContext *moc = [self.appDelegate managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSStory"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE] ];

    NSError *error = nil;
    self.stories = [NSMutableArray arrayWithArray:[moc executeFetchRequest:request error:&error]];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

    self.cached = self.stories;
}

- (void)cacheLocalData:(NSArray *)localData {
    for (FRSStory *story in self.cached) {
        [self.appDelegate.managedObjectContext deleteObject:story];
    }

    [self.appDelegate.managedObjectContext save:Nil];
    [self.appDelegate saveContext];
}

- (FRSStory *)storyExists:(NSString *)storyID {
    for (FRSStory *story in self.stories) {
        if ([story.uid isEqualToString:storyID]) {
            return story;
        }
    }

    return Nil;
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loadNoMore) {
        return self.stories.count;
    }

    return (self.stories.count == 0) ? 0 : self.stories.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.stories.count) {
        return 0;
    }

    if (indexPath.row >= self.stories.count - 1) {
        return loadingCellHeight;
    }

    FRSStory *story = self.stories[indexPath.row];
    return [story heightForStory];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // if we're loading more data
    if (indexPath.row == self.stories.count - 1) {
        FRSLoadingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }

    if (indexPath.row > numberRead) {
        numberRead = indexPath.row;
    }

    FRSStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:storyCellIdentifier];

    if (indexPath.row == self.stories.count - 5 || (indexPath.row == self.stories.count && self.stories.count < 4)) {
        [self fetchMoreStories];
    }

    return cell;
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSStoryTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[cell class] isSubclassOfClass:[FRSStoryTableViewCell class]]) {
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

        cell.imageBlock = ^(NSInteger imageIndex) {
          [weakSelf handleImagePress:indexPath imageIndex:imageIndex];
        };

        [cell configureCell];
    }
}

- (void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)handleImagePress:(NSIndexPath *)cellIndex imageIndex:(NSInteger)imageIndex {

    [self.navigationController setNavigationBarHidden:YES animated:NO];

    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:[self.stories objectAtIndex:cellIndex.row]];
    detailView.navigationController = self.navigationController;
    [detailView scrollToGalleryIndex:imageIndex];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    self.navigationItem.rightBarButtonItem.customView.alpha = 0;
}

- (void)readMore:(NSInteger)index {

    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:[self.stories objectAtIndex:index]];
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
    [self expandNavBar:nil];
}

- (void)handleLikeLabelTapped:(FRSContentActionsBar *)actionBar {
    //    FRSDualUserListViewController *vc = [[FRSDualUserListViewController alloc] initWithGallery:self.gallery.uid];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleRepostLabelTapped:(FRSContentActionsBar *)actionBar {
    //    FRSDualUserListViewController *vc = [[FRSDualUserListViewController alloc] initWithGallery:self.gallery.uid];
    //    vc.didTapRepostLabel = YES;
    //    [self.navigationController pushViewController:vc animated:YES];
}

@end
