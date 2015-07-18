//
//  StoryCellMosaicHeader.h
//  FrescoNews
//
//  Created by Fresco News on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSStory;

@interface StoryCellMosaicHeader : UITableViewCell

+ (NSString *)identifier;

- (void)populateViewWithStory:(FRSStory *)story;

@end
