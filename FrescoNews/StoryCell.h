//
//  StoryCell.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSTag.h"

@interface StoryCell : UITableViewCell
@property (weak, nonatomic) FRSTag *frsTag;
@property (strong, nonatomic) NSMutableArray *imagesArray;
+ (NSString *)identifier;
- (void)setFRSTag:(FRSTag *)tag;
@end

