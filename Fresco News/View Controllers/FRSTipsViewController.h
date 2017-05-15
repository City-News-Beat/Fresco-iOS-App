//
//  FRSTipsViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"


@interface FRSTipsViewController : FRSBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *videosArray;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *spinner;

@end
