//
//  ProfileViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError* error);

@import UIKit;

#import "FRSBaseViewController.h"
#import "GalleriesViewController.h"

@interface ProfileViewController : FRSBaseViewController

@property (weak, nonatomic) GalleriesViewController *galleriesViewController;

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock;

@end
