//
//  FRSFeedTable.h
//  Fresco
//
//  Created by Philip Bernstein on 5/31/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fresco.h"
#import "FRSGallery.h"
#import "FRSStory.h"
#import "FRSGalleryCell.h"
#import "FRSStoryCell.h"

@interface FRSFeedTable : UITableView
@property NSArray *galleries;
@property (weak, nonatomic) id<UIScrollViewDelegate> scrollDelegate;
@property (weak, nonatomic) UINavigationController *navigationController;
// loading more data
typedef NSArray *(^FRSFeedTableLoadMoreRequest)(int offset, NSString *offsetIdentifier); // asks for more data based off index path of last object we currently have, as well as the UID of the gallery, expects (demands) an NSArray in response, not recommended to capture self (or any external object) strongly in this block (will retain table even if discarded if you do, use a weak reference to self)
@property BOOL shouldLoadMore;
@property FRSFeedTableLoadMoreRequest loadMoreBlock;
@end
