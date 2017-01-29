//
//  FRSFollowingTable.h
//  Fresco
//
//  Created by Philip Bernstein on 4/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGallery.h"
#import "FRSGalleryCell.h"
#import "FRSScrollingViewController.h"
#import "FRSStoryView.h"

@protocol FRSFollowingTableDelegate
- (void)expandGallery:(FRSGallery *)gallery;
- (void)expandStory:(FRSStory *)story;
@end
@interface FRSFollowingTable : UITableView <UITableViewDelegate, UITableViewDataSource, FRSGalleryViewDelegate, FRSStoryViewDelegate> {
    NSInteger numberOfPosts;
    UIView *awkwardView;
    BOOL isReloading;
    BOOL isFinished;

    CGPoint lastScrollOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
}
@property (retain, nonatomic) NSArray *galleries;
@property (weak, nonatomic) id<FRSFollowingTableDelegate> leadDelegate;
@property (weak, nonatomic) id<UIScrollViewDelegate> scrollDelegate;
- (void)reloadFollowing;
- (void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)indexPath;

@end
