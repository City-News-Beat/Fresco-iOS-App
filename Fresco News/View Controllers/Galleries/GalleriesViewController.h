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
#import "ProfileHeaderViewController.h"

@class FRSUser;

@interface GalleriesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, GalleryTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *galleries;

@property (weak, nonatomic) UIViewController *containingViewController;

@property (weak, nonatomic) ProfileHeaderViewController *profileHeaderViewController;

@property (weak, nonatomic) IBOutlet UIView *viewProfileHeader;

/**
 *  Refresh function
 */

- (void)refresh;

- (void)reloadData;

@end
