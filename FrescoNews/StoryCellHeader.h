//
//  StoryViewHeaderCell.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSStory;
@interface StoryCellHeader : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
+ (NSString *)identifier;
- (void)populateViewWithStory:(FRSStory *)story;
@end
