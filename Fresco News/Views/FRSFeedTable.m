//
//  FRSFeedTable.m
//  Fresco
//
//  Created by Philip Bernstein on 5/31/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFeedTable.h"
#import "UIColor+Fresco.h"
#import "FRSAppDelegate.h"
#import "FRSGalleryExpandedViewController.h"

@implementation FRSFeedTable
@synthesize navigationController = _navigationController, feed = _feed, loadMoreBlock = _loadMoreBlock;

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

-(NSArray *)feed {
    return _feed;
}

-(void)setFeed:(NSArray *)feed {
    _feed = feed;
    [self reloadData];
}

-(BOOL)shouldHaveTextLimit {
    return TRUE;
}

-(BOOL)shouldHaveActionBar {
    return TRUE;
}

-(void)commonInit {
    self.showsVerticalScrollIndicator = FALSE;
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = (id<UITableViewDelegate>)self;
    self.dataSource = (id<UITableViewDataSource>)self;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < _feed.count) {
        id representedObject = [_feed objectAtIndex:indexPath.row];
        
        if ([[representedObject class] isSubclassOfClass:[FRSGallery class]]) {
            FRSGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:galleryCellIdentifier];
            
            if (!cell) {
                cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:galleryCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.delegate = self;
            
            return cell;
        }
        else if ([[representedObject class] isSubclassOfClass:[FRSStory class]]) {
            FRSStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:storyCellIdentifier];
            
            if (!cell) {
                cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:storyCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.actionBlock = ^{
                
            };
        
            return cell;
        }
    
    }
 
    return Nil; // replace with loading more
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feed.count;
}

-(void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[self.feed objectAtIndex:indexPath.row]];
    vc.shouldHaveBackButton = YES;
    
    FRSScrollingViewController *scroll = (FRSScrollingViewController *)self.scrollDelegate;
    
    scroll.navigationItem.title = @"";
    
    [scroll.navigationController pushViewController:vc animated:YES];
    scroll.navigationController.interactivePopGestureRecognizer.enabled = YES;
    scroll.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [(FRSScrollingViewController *)self.scrollDelegate hideTabBarAnimated:YES];
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }
    
    if (cell.gallery == self.feed[indexPath.row]) {
        return;
    }
    
    cell.gallery = self.feed[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell clearCell];
        [cell configureCell];
    });
    
    __weak typeof(self) weakSelf = self;
    
    cell.shareBlock = ^void(NSArray *sharedContent) {
        [weakSelf showShareSheetWithContent:sharedContent];
    };
    
    cell.readMoreBlock = ^void(NSArray *sharedContent) {
        [self readMore:indexPath];
    };
}

-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityController animated:YES completion:nil];
}

-(void)reloadData {
    [self fetchfeed];
}

-(void)fetchfeed {
    
}

-(void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification {
    
    NSArray *filteredArray = [self.feed filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];
    
    if (!filteredArray.count) return;
    // push gallery detail view
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.feed.count) {
        return 0;
    }
    
    FRSGallery *gallery = [self.feed objectAtIndex:indexPath.row];
    return [gallery heightForGallery];
}

-(void)followStory {
    NSLog(@"Follow Story");
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 90)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 128;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollDelegate) {
        [self.scrollDelegate scrollViewDidScroll:scrollView];
    }
    
    NSArray *visibleCells = [self visibleCells];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL taken = FALSE;
        
        for (FRSGalleryCell *cell in visibleCells) {
            
            if (cell.frame.origin.y - self.contentOffset.y < 300 && cell.frame.origin.y - self.contentOffset.y > 100) {
                
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


@end
