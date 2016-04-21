//
//  FRSStoryDetailViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 3/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryDetailViewController.h"
#import "FRSGalleryCell.h"
#import <MagicalRecord/MagicalRecord.h>
#import "FRSStory+CoreDataProperties.h"
#import "FRSAppDelegate.h"
#import "DGElasticPullToRefresh.h"
#import "FRSGalleryExpandedViewController.h"

@interface FRSStoryDetailViewController ()

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@end

@implementation FRSStoryDetailViewController
@synthesize stories = _stories, story = _story;
static NSString *galleryCell = @"GalleryCellReuse";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableView];
    [self configureNavigationBar];
    [self configureSpinner];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeStatusBarNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addStatusBarNotification];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    self.galleriesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.galleriesTable.frame.size.width, 1)];
    self.galleriesTable.tableFooterView.backgroundColor = [UIColor clearColor];

}

-(void)setupTableView {
   // [self.galleriesTable registerClass:[FRSGalleryCell class] forCellReuseIdentifier:@"gallery-cell"];
    self.galleriesTable.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.galleriesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.galleriesTable.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.galleriesTable.scrollEnabled = NO;
}

-(void)configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissDetail)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"follow-white"] style:UIBarButtonItemStylePlain target:self action:@selector(followStory)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = [self.story.title uppercaseString];
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self.navigationItem setTitleView:label];

}

-(void)dismissDetail{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stories.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FRSGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
    
    if (!cell) {
        cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.navigationController = self.navigationController;

    }
    
    
    cell.delegate = self;

    return cell;
}

-(void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[self.stories objectAtIndex:indexPath.row]];
    vc.shouldHaveBackButton = YES;
    
    
    self.navigationItem.title = @"";
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    //[self hideTabBarAnimated:YES];
    
}


-(void)playerWillPlay:(AVPlayer *)player {
    for (FRSGalleryCell *cell in [self.galleriesTable visibleCells]) {
        for (FRSPlayer *cellPlayer in cell.players) {
            if (cellPlayer != player) {
                [player pause];
            }
        }
    }
}


-(void)viewDidLayoutSubviews {
    if ([self.galleriesTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.galleriesTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.galleriesTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.galleriesTable setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }
    
    if (cell.gallery == self.stories[indexPath.row]) {
        return;
    }
    
    cell.gallery = self.stories[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell clearCell];
        [cell configureCell];
    });
    
    __weak typeof(self) weakSelf = self;
    
    cell.shareBlock = ^void(NSArray *sharedContent) {
        [weakSelf showShareSheetWithContent:sharedContent];
    };
    
    cell.readMoreBlock = ^void(NSArray *sharedContent) {
        [weakSelf readMore:indexPath];
    };
}

-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

-(void)reloadData {
    [self fetchGalleries];
}

-(void)fetchGalleries {
    
    self.stories = [[NSMutableArray alloc] init];
    
    [[FRSAPIClient sharedClient] fetchGalleriesInStory:self.story.uid completion:^(NSArray *galleries, NSError *error) {
        FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        for (NSDictionary *gallery in galleries) {
            FRSGallery *galleryObject = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:delegate.managedObjectContext];
            [galleryObject configureWithDictionary:gallery context:delegate.managedObjectContext];
            [self.stories addObject:galleryObject];
            [self.loadingView stopLoading];
            [self.loadingView removeFromSuperview];
            self.galleriesTable.scrollEnabled = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.galleriesTable reloadData];
        });
    }];
}

-(void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification {
    
    NSArray *filteredArray = [self.stories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];
    
    if (!filteredArray.count) return;
    // push gallery detail view
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.stories.count) {
        return 0;
    }
    
    FRSGallery *gallery = [self.stories objectAtIndex:indexPath.row];
    return [gallery heightForGallery];
}

-(void)followStory {
    NSLog(@"Follow Story");
}

-(void)scrollToGalleryIndex:(NSInteger)index {
    
}

-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 -10, [UIScreen mainScreen].bounds.size.height/2  -44 -10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.galleriesTable addSubview:self.loadingView];
}


#pragma mark - Status Bar

-(void)statusBarTappedAction:(NSNotification*)notification{
    if (self.galleriesTable.contentOffset.y >= 0) {
        [self.galleriesTable setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)addStatusBarNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:kStatusBarTappedNotification
                                               object:nil];
}

-(void)removeStatusBarNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}



@end
