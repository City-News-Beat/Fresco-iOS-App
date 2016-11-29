//
//  FRSFollowingController.h
//  Fresco
//
//  Created by Philip Bernstein on 6/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGElasticPullToRefreshLoadingViewCircle.h"
@protocol FRSFollowingControllerDelegate
-(void)storyClicked:(FRSStory *)story;
-(void)galleryClicked:(FRSGallery *)gallery;
@end
@interface FRSFollowingController : NSObject <UITableViewDelegate, UITableViewDataSource>
{
    DGElasticPullToRefreshLoadingViewCircle *loadingView;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, retain) NSArray *feed;
@property (nonatomic, weak) id<FRSFollowingControllerDelegate> delegate;
@property (weak, nonatomic) id<UIScrollViewDelegate> scrollDelegate;

-(void)reloadData;
@end
