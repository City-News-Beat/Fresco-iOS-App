//
//  FRSHomeViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "Fresco.h"
#import "FRSGalleryView.h"
#import "FRSSplitTableView.h"
#import "FRSFollowingController.h"
#import "FRSAlertView.h"

@interface FRSHomeViewController : FRSScrollingViewController <FRSGalleryViewDelegate, FRSAlertViewDelegate>
{
    BOOL delayClear;
    BOOL needsUpdate;
    BOOL hasLoadedOnce;
    BOOL wasAuthenticated;
    DGElasticPullToRefreshLoadingViewCircle* loadingView;
    NSArray *pulledFromCache;
    NSMutableArray *reloadedFrom;
    
    FRSSplitTableView *tableScroller;
    FRSFollowingController *followingController;
    UITableView *followTable;
    NSDate *entry;
    NSDate *exit;
    NSInteger numberRead;
    NSIndexPath *lastIndexPath;
}
@property BOOL loadNoMore;
-(void)loadData;
-(void)presentTOS;
@end
