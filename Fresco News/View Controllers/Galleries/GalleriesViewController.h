//
//  GalleriesViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

#import "FRSBaseViewController.h"
#import "GalleryTableViewCell.h"
#import "ProfileHeaderViewController.h"
#import "FRSTableViewController.h"

@class FRSUser;

@interface GalleriesViewController : FRSTableViewController <GalleryTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *galleries;

@property (weak, nonatomic) UIViewController *containingViewController;

@property (weak, nonatomic) ProfileHeaderViewController *profileHeaderViewController;

@property (assign, nonatomic) BOOL refreshDisabled;


/**
 *  Refresh function
 */

- (void)refresh;

@end
