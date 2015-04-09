//
//  GalleriesViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError* error);

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface GalleriesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *galleries;
- (void)refresh;
@end
