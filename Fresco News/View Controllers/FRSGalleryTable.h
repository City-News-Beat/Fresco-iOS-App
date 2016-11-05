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
typedef NSArray *(^FRSGalleryTableLoadMoreRequest)(int offset, NSString *offsetIdentifier); // asks for more data based off index path of last object we currently have, as well as the UID of the gallery, expects (demands) an NSArray in response, not recommended to capture self (or any external object) strongly in this block (will retain table even if discarded if you do, use a weak reference to self)
@property BOOL shouldLoadMore;
@property FRSGalleryTableLoadMoreRequest loadMoreBlock;

@end
