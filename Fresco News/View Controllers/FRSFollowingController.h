//
//  FRSFollowingController.h
//  Fresco
//
//  Created by Philip Bernstein on 6/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGElasticPullToRefreshLoadingViewCircle.h"

@interface FRSFollowingController : NSObject <UITableViewDelegate, UITableViewDataSource>
{
    DGElasticPullToRefreshLoadingViewCircle *loadingView;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, retain) NSArray *feed;
@end
