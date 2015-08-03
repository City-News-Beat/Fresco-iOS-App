//
//  HomeViewController.h
//  FrescoNews
//
//  Created by Fresco News on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
@import Parse;
#import "FRSBaseViewController.h"
#import "GalleriesViewController.h"

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError *error);

@interface HighlightsViewController : FRSBaseViewController

@property (weak, nonatomic) GalleriesViewController *galleriesViewController;

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock withRefresh:(BOOL)refresh;

@end

