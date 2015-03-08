//
//  FRSStoryListCell.h
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSPost.h"

@interface FRSStoryListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *bylineLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (nonatomic) BOOL didTransition;

@property (weak, nonatomic) FRSPost *post;

- (void)setPost:(FRSPost *)post;

+ (NSString *)identifier;

@end
