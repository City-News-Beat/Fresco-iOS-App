//
//  FRSStorySearchTableViewCell.h
//  Fresco
//
//  Created by Maurice Wu on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const storySearchCellIdentifier = @"story-search-cell";
static CGFloat const storySearchCellHeight = 56;

@interface FRSStorySearchTableViewCell : UITableViewCell

- (void)loadDataWithTitle:(NSString *)title andImageURL:(NSURL *)imageURL;

@end
