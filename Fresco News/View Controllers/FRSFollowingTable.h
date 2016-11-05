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

@interface FRSFollowingTable : UITableView <UITableViewDelegate, UITableViewDataSource, FRSGalleryViewDelegate>
{
    NSInteger numberOfPosts;
    UIView *awkwardView;
    BOOL isReloading;
    BOOL isFinished;
}
@property (retain, nonatomic, readonly) NSArray *galleries;

@property (weak, nonatomic) id<UIScrollViewDelegate> scrollDelegate;
-(void)reloadFollowing;
-(void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)indexPath;

@end
