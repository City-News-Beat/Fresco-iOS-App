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
}

-(void)reloadData {
    [super reloadData];
}

-(void)fetchGalleries {
    
}

-(void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)indexPath {
    
    FRSGallery *gallery = _galleries[indexPath.row];
    
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    vc.shouldHaveBackButton = YES;
//    [super showNavBarForScrollView:self.inputViewController animated:NO];

    self.inputViewController.navigationController.title = @"";
    
    [self.inputViewController.navigationController pushViewController:vc animated:YES];
    self.inputViewController.navigationController.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.inputViewController.navigationController.navigationController.interactivePopGestureRecognizer.delegate = nil;

//    [self.inputViewController hideTabBarAnimated:YES];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_galleries count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if ([[[_galleries objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
        
        if (!cell){
            cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        }
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        FRSGalleryCell *galCell = (FRSGalleryCell *)cell;
        [galCell clearCell];
        
        galCell.gallery = _galleries[indexPath.row];
        [galCell configureCell];
        
        __weak typeof(self) weakSelf = self;
        
        galCell.shareBlock = ^void(NSArray *sharedContent) {
            [weakSelf showShareSheetWithContent:sharedContent];
        };
        
        galCell.readMoreBlock = ^(NSArray *bullshit){
            [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
        };
    }
    else {
        FRSStoryCell *storyCell = (FRSStoryCell *)cell;
        [storyCell clearCell];
        
        storyCell.story = _galleries[indexPath.row];
        [storyCell configureCell];
        
        __weak typeof(self) weakSelf = self;
        
        storyCell.shareBlock = ^void(NSArray *sharedContent) {
            [weakSelf showShareSheetWithContent:sharedContent];
        };
        
        storyCell.readMoreBlock = ^(NSArray *bullshit){
//            [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
            [weakSelf readMore:indexPath];
        };
    }
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
    
    NSLog(@"HT: %f", height);
    
    if (height <= 0) {
        height = 200;
    }
    
    return height;
}

@end
