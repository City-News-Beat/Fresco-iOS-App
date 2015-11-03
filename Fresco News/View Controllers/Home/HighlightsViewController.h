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

/**
 *  Performs data call to fetch initial set of galleries
 *
 *  @param refresh       To perform refresh of content or not
 *  @param responseBlock Completion block for refresh
 */

- (void)performNecessaryFetchWithRefresh:(BOOL)refresh withResponseBlock:(FRSRefreshResponseBlock)responseBlock;

@end

