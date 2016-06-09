//
//  FRSHomeViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "Fresco.h"
#import "FRSGalleryView.h"
#import "FRSSplitTableView.h"

@interface FRSHomeViewController : FRSScrollingViewController <FRSGalleryViewDelegate>
{
    BOOL delayClear;
    BOOL needsUpdate;
    
    NSArray *pulledFromCache;
    NSMutableArray *reloadedFrom;
    
    FRSSplitTableView *tableScroller;
}
@property BOOL loadNoMore;
@end
