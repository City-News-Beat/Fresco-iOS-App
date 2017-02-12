//
//  FRSStorySearchTableViewCell.m
//  Fresco
//
//  Created by User on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSStorySearchTableViewCell.h"
#import "Haneke.h"

@interface FRSStorySearchTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *storyImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation FRSStorySearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.storyImageView.layer.cornerRadius = 16;
    self.storyImageView.layer.masksToBounds = YES;
}

- (void)loadDataWithTitle:(NSString *)title andImageURL:(NSURL *)imageURL {
    self.titleLabel.text = title;
    [self.storyImageView hnk_setImageFromURL:imageURL];
}

@end
