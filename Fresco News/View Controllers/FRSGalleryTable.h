//
//  FRSFollowingTable.h
//  Fresco
//
//  Created by Philip Bernstein on 4/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fresco.h"
#import "FRSGallery.h"
#import "FRSGalleryCell.h"
#import "FRSScrollingViewController.h"

@interface FRSGalleryTable : UITableView <UITableViewDelegate, UITableViewDataSource, FRSGalleryViewDelegate>
@property NSArray *galleries;
@property (weak, nonatomic) id<UIScrollViewDelegate> scrollDelegate;

// loading more data
@property BOOL shouldLoadMore;
typedef NSArray *(^FRSGalleryTableLoadMoreRequest)(int offset, NSString *offsetIdentifier);

@end
