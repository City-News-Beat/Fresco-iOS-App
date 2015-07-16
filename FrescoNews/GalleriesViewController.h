//
//  GalleriesViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError* error);

@import UIKit;
#import "FRSBaseViewController.h"
#import "GalleryTableViewCell.h"

@class FRSUser;

@interface GalleriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GalleryTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *galleries;
@property (strong, nonatomic) FRSUser *frsUser;
@property (weak, nonatomic) UIViewController *containingViewController;
@property (weak, nonatomic) IBOutlet UIView *viewProfileHeader;

/*
** Refresh function
*/

- (void)refresh;

@end
