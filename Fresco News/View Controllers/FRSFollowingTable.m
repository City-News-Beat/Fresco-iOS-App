//
//  FRSFollowingTable.m
//  Fresco
//
//  Created by Philip Bernstein on 4/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowingTable.h"
#import "UIColor+Fresco.h"
#import "FRSScrollingViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSAwkwardView.h"
#import "FRSStoryTableViewCell.h"
#import "FRSStoryDetailViewController.h"
#import "FRSUserManager.h"
#import "FRSFeedManager.h"
#import "FRSStory.h"
#import "FRSLoadingTableViewCell.h"

@implementation FRSFollowingTable
@synthesize navigationController = _navigationController;

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (BOOL)shouldHaveTextLimit {
    return TRUE;
}

- (BOOL)shouldHaveActionBar {
    return TRUE;
}

- (void)loadGalleries:(NSArray *)galleries {
    [self reloadData];
}

- (void)commonInit {
    self.showsVerticalScrollIndicator = FALSE;
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;

    [self registerNib:[UINib nibWithNibName:@"FRSLoadingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSGalleryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:galleryCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSStoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyCellIdentifier];

}

- (void)reloadFollowing {
    [[FRSFeedManager sharedInstance] fetchFollowing:^(NSArray *galleries, NSError *error) {
      if (error) {
          isFinished = NO;
          return;
      }
        
      if (galleries.count == 0) {
          if (!awkwardView) {
              awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 175 / 2, self.frame.size.height / 2 - 125 / 2 + 64, 175, 125)];
          }
          [self addSubview:awkwardView];
      } else {
          [awkwardView removeFromSuperview];
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        self.feed = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:NO]];
        [self reloadData];
      });
    }];
}

- (void)viewDidLayoutSubviews {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityController animated:YES completion:nil];

    NSString *url = content[0];
    url = [[url componentsSeparatedByString:@"/"] lastObject];
    [FRSTracker track:galleryShared
           parameters:@{ @"gallery_id" : url,
                         @"shared_from" : @"following" }];
}

- (void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[self.feed objectAtIndex:indexPath.row]];
    [vc configureBackButtonAnimated:YES];

    FRSScrollingViewController *scroll = (FRSScrollingViewController *)self.scrollDelegate;

    scroll.navigationItem.title = @"";

    [scroll.navigationController pushViewController:vc animated:YES];
    scroll.navigationController.interactivePopGestureRecognizer.enabled = YES;
    scroll.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [(FRSScrollingViewController *)self.scrollDelegate hideTabBarAnimated:YES];
}

- (void)readMoreStory:(NSIndexPath *)indexPath {
    FRSStoryTableViewCell *storyCell = [self cellForRowAtIndexPath:indexPath];
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:storyCell.story];
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollDelegate) {
        [self.scrollDelegate scrollViewDidScroll:scrollView];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.feed.count && self.feed.count != 0 && self.feed != nil) {
        FRSLoadingTableViewCell *cell = [self dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    if ([[[self.feed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
        FRSGalleryTableViewCell *cell = [self dequeueReusableCellWithIdentifier:galleryCellIdentifier];
        cell.navigationController = self.navigationController;
        cell.gallery = self.feed[indexPath.row];

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
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        return cell;
    } else if ([[[self.feed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSStory class]]) {
        FRSStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:storyCellIdentifier];
        return cell;
    }
    return [UITableViewCell new];
}

- (void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)indexPath {
    if (self.feed.count > indexPath.row) {
        id representedObject = self.feed[indexPath.row];

        if ([[representedObject class] isSubclassOfClass:[FRSGallery class]]) {
            if (self.leadDelegate) {
                [self.leadDelegate expandGallery:representedObject];
            }
        } else if ([[representedObject class] isSubclassOfClass:[FRSStory class]]) {
            if (self.leadDelegate) {
                [self.leadDelegate expandStory:representedObject];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]]) {
        FRSGalleryTableViewCell *galleryCell = (FRSGalleryTableViewCell *)cell;
        galleryCell.trackedScreen = FRSTrackedScreenFollowing;
    } else if ([[cell class] isSubclassOfClass:[FRSStoryTableViewCell class]]) {
        FRSStoryTableViewCell *storyCell = (FRSStoryTableViewCell *)cell;
        storyCell.storyView.navigationController = self.navigationController;
        storyCell.storyView.delegate.navigationController = self.navigationController;
        [storyCell clearCell];

        storyCell.story = self.feed[indexPath.row];
        [storyCell configureCell];

        __weak typeof(self) weakSelf = self;

        storyCell.shareBlock = ^void(NSArray *sharedContent) {
          [weakSelf showShareSheetWithContent:sharedContent];
        };

        storyCell.readMoreBlock = ^(NSArray *bullshit) {
          [weakSelf readMoreStory:indexPath];
        };
    }

    if (indexPath.row >= self.feed.count - 5) {
        [self loadMore];
    }
}

- (void)loadMore {
    if (isReloading || isFinished) {
        return;
    }
    
    isReloading = YES;
    FRSGallery *gallery = [self.feed lastObject];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSString *timeStamp = [dateFormat stringFromDate:gallery.createdDate];
    
    [[FRSFeedManager sharedInstance] fetchFollowing:timeStamp
                                         completion:^(NSArray *galleries, NSError *error) {
                                             
                                             if (galleries.count == 0 && !error) {
                                                 isFinished = YES;
                                             }
                                             
                                             isReloading = NO;
                                             
                                             // Mutable array from current following feed to be set as the main feed later
                                             NSMutableArray *paginatedFeed = [self.feed mutableCopy];
                                             // Array from the response object to be parsed
                                             NSArray *responseFeed = [galleries copy];
                                             // Parse response feed
                                             responseFeed = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:NO]];
                                             // Add parsed feed to paginated feed
                                             [paginatedFeed addObjectsFromArray:responseFeed];
                                             // Set main feed to paginated feed
                                             self.feed = paginatedFeed;
                                             // Reload tableview
                                             [self reloadData];
                                         }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 0;

    if ([[self.feed[indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
        FRSGallery *gallery = self.feed[indexPath.row];
        height = [gallery heightForGallery];
    } else if ([[self.feed[indexPath.row] class] isSubclassOfClass:[FRSStory class]]) {
        FRSStory *story = self.feed[indexPath.row];
        height = [story heightForStory];
    } else if (indexPath.row >= self.feed.count) {
        return loadingCellHeight;
    }

    return height;
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
//    if (needsUpdate) {
//        needsUpdate = NO;
//    }
    
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
    //Pause currently playing players
    [self pausePlayers];
    
    for (FRSGalleryTableViewCell *cell in self.visibleCells) {

        //Proceed further for gallery cell only.
        if (![cell isKindOfClass:[FRSGalleryTableViewCell class]]) continue;

        //Calculate cell Y position relative to the table
        CGFloat cellRelativeYPosition = cell.frame.origin.y - self.contentOffset.y;
        
        if (cellRelativeYPosition < 0.6*self.frame.size.height && cellRelativeYPosition > 0) {
            //Play the cell which starts at atleast 0 to 60% of the table
            [cell play];
            
            //Need not play any other cells. so break.
            break;
        }
    }
}

- (void)pausePlayers {
    for (FRSGalleryTableViewCell *cell in [self visibleCells]) {
        if (![[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]]) {
            continue;
        }
        
        //pause the player in the cell
        [cell pause];
    }
}


@end
