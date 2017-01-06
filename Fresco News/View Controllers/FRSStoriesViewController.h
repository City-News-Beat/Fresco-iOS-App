//
//  FRSStoriesViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "FRSBaseViewController.h"
#import "Fresco.h"
#import "FRSStoryDetailViewController.h"

@interface FRSStoriesViewController : FRSScrollingViewController {
    BOOL firstOpen;
    NSDate *entry;
    NSDate *exit;
    NSInteger numberRead;
}
@property BOOL loadNoMore;
- (void)reloadData;
@end
