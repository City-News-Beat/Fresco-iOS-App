//
//  GalleriesViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError* error);

@import UIKit;
#import "FRSBaseViewController.h"

@class FRSUser;

@interface GalleriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *galleries;
@property (strong, nonatomic) FRSUser *frsUser;
@property (weak, nonatomic) UIViewController *containingViewController;
@property (weak, nonatomic) IBOutlet UIView *viewProfileHeader;

/*
** Refresh function
*/

- (void)refresh;

/*
** Index of cell that is currently playing a video
*/

@property (nonatomic) NSIndexPath *playingIndex;


/*
** Returns condition if request in running to DB
*/

@property (nonatomic) BOOL isRunning;

@end
