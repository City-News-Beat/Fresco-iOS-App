//
//  FRSFollowingTable.m
//  Fresco
//
//  Created by Philip Bernstein on 4/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowingTable.h"
#import "UIColor+Fresco.h"
#import "FRSAPIClient.h"
#import "FRSAppDelegate.h"
#import "FRSScrollingViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSAwkwardView.h"
#import "FRSStoryCell.h"
#import "FRSStoryDetailViewController.h"


@implementation FRSFollowingTable
@synthesize navigationController = _navigationController, galleries = _galleries;


-(void)setGalleries:(NSArray *)galleries {
    _galleries = galleries;
}

-(NSArray *)galleries {
    return _galleries;
}
-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(BOOL)shouldHaveTextLimit {
    return TRUE;
}

-(BOOL)shouldHaveActionBar {
    return TRUE;
}

-(void)loadGalleries:(NSArray *)galleries {
    [self reloadData];
}
-(void)commonInit {
    self.showsVerticalScrollIndicator = FALSE;
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
    
    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        
        if (galleries.count == 0) {
            if (!awkwardView) {
                awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 175/2, self.frame.size.height/2 -125/2 +64, 175, 125)];
            }
            [self addSubview:awkwardView];
        }
        else {
            [awkwardView removeFromSuperview];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _galleries = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:FALSE]];
            numberOfPosts = [_galleries count];
            [self reloadData];
        });
    }];
}

-(void)reloadFollowing {
    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        
        if (galleries.count == 0) {
            if (!awkwardView) {
                awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 175/2, self.frame.size.height/2 -125/2 +64, 175, 125)];
            }
            [self addSubview:awkwardView];
        }
        else {
            [awkwardView removeFromSuperview];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _galleries = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:FALSE]];
            numberOfPosts = [_galleries count];
            [self reloadData];
            isFinished = FALSE;
        });
    }];
    
}

-(void)playerWillPlay:(AVPlayer *)player {
    for (FRSGalleryCell *cell in [self visibleCells]) {
        if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]] || !cell.galleryView.players) {
            continue;
        }
        for (FRSPlayer *cellPlayer in cell.players) {
            if (cellPlayer != player) {
                [player pause];
            }
        }
    }
}


-(void)viewDidLayoutSubviews {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityController animated:YES completion:nil];
    [FRSTracker track:@"Gallery Shared" parameters:@{@"content":content.firstObject}];
}

-(void)reloadData {
    [super reloadData];
}

-(void)fetchGalleries {
    
}

-(void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[_galleries objectAtIndex:indexPath.row]];
    vc.shouldHaveBackButton = YES;
    
    FRSScrollingViewController *scroll = (FRSScrollingViewController *)self.scrollDelegate;
    
    scroll.navigationItem.title = @"";
    
    [scroll.navigationController pushViewController:vc animated:YES];
    scroll.navigationController.interactivePopGestureRecognizer.enabled = YES;
    scroll.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [(FRSScrollingViewController *)self.scrollDelegate hideTabBarAnimated:YES];
}

-(void)readMoreStory:(NSIndexPath *)indexPath {
    FRSStoryCell *storyCell = [self cellForRowAtIndexPath:indexPath];
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:storyCell.story];
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
}

-(FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

-(void)followStory {
    NSLog(@"Follow Story");
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 125)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 125;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollDelegate) {
        [self.scrollDelegate scrollViewDidScroll:scrollView];
    }
    
    CGPoint scrollVelocity = [[scrollView panGestureRecognizer] velocityInView:self];
    if (scrollVelocity.y > maxScrollVelocity) {
        
    }
    
    NSArray *visibleCells = [self visibleCells];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL taken = FALSE;
        
        for (FRSGalleryCell *cell in visibleCells) {
            
            /*
             Start playback mid frame -- at least 300 from top & at least 100 from bottom
             */
            if (cell.frame.origin.y - self.contentOffset.y < 300 && cell.frame.origin.y - self.contentOffset.y > 0) {
                
                if (!taken) {
                    taken = TRUE;
                    [cell play];
                }
                
            }
            else {
                [cell pause];
            }
        }
        
    });
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.scrollDelegate) {
        [self.scrollDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_galleries count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if ([[[_galleries objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
        return [self highlightCellForIndexPath:indexPath];
    }
    else if ([[[_galleries objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSStory class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
        
        if (!cell){
            cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UITableViewCell *)highlightCellForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.galleries.count && self.galleries.count != 0 && self.galleries != Nil) { // we're reloading
        
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = 20;
        cell.frame = cellFrame;
        return cell;
    }
    
    FRSGalleryCell *cell = [self dequeueReusableCellWithIdentifier:@"gallery-cell"];
    
    if (!cell) {
        cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.navigationController = self.navigationController;
    }
    
    cell.gallery = self.galleries[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
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

-(void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)indexPath {
    if (_galleries.count > indexPath.row) {
        id representedObject = _galleries[indexPath.row];
        
        if ([[representedObject class] isSubclassOfClass:[FRSGallery class]]) {
            if (self.leadDelegate) {
                [self.leadDelegate expandGallery:representedObject];
            }
        }
        else if ([[representedObject class] isSubclassOfClass:[FRSStory class]]) {
            if (self.leadDelegate) {
                [self.leadDelegate expandStory:representedObject];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        
    }
    else {
        FRSStoryCell *storyCell = (FRSStoryCell *)cell;
        storyCell.storyView.navigationController = self.navigationController;
        storyCell.storyView.delegate.navigationController = self.navigationController;
        [storyCell clearCell];
        
        storyCell.story = _galleries[indexPath.row];
        [storyCell configureCell];
        
        __weak typeof(self) weakSelf = self;
        
        storyCell.shareBlock = ^void(NSArray *sharedContent) {
            [weakSelf showShareSheetWithContent:sharedContent];
        };
        
        storyCell.readMoreBlock = ^(NSArray *bullshit){
            //            [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
            [weakSelf readMoreStory:indexPath];
        };
    }
    
    if (indexPath.row >= self.galleries.count-5) {
        [self loadMore];
    }
}

-(void)loadMore {
    
    if (isReloading || isFinished) {
        return;
    }
    
    isReloading = TRUE;
    FRSGallery *gallery = [self.galleries lastObject];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSString *timeStamp = [dateFormat stringFromDate:gallery.editedDate];
    
    FRSUser *authUser = [[FRSAPIClient sharedClient] authenticatedUser];
    NSString *userID = authUser.uid;
    
    NSString *endpoint = [NSString stringWithFormat:followingFeed, userID];
    
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, timeStamp];
    
    [[FRSAPIClient sharedClient] get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        isReloading = FALSE;
        
        
        NSArray *response = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE]];
        
        if (response.count == 0) {
            isFinished = TRUE;
        }
        
        NSMutableArray *newGalleries = [self.galleries mutableCopy];
        [newGalleries addObjectsFromArray:response];
        self.galleries = newGalleries;
        [self reloadData];
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float height = 0;
    
    if ([[_galleries[indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
        FRSGallery *gallery = _galleries[indexPath.row];
        height = [gallery heightForGallery];
    }
    else {
        FRSStory *story = _galleries[indexPath.row];
        height = [story heightForStory];
    }
    
    if (height <= 0) {
        height = 200;
    }
    
    return height;
}

@end
