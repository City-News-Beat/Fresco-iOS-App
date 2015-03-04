//
//  FRSStoryListCell.h
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSPost.h"

@interface FRSStoryListCell: UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePlaceLabel;
@property (nonatomic) BOOL didTransition;

@property (weak, nonatomic) FRSPost *post;

- (void)setPost:(FRSPost *)post;

+ (NSString *)identifier;

@end
