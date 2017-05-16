//
//  FRSTipsTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 5/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsTableViewCell.h"

@interface FRSTipsTableViewCell ()

@property (strong, nonatomic) NSString *videoURL;

@end

@implementation FRSTipsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.actionButton.adjustsImageWhenHighlighted = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle thumbnailURL:(NSString *)thumbnailURL videoURL:(NSString *)videoURL {
    self.titleLabel.text = title.uppercaseString;
    self.bodyLabel.text = subtitle;
    [self.thumbnailImageView setImage:[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]]];
    self.videoURL = videoURL;
}

- (IBAction)actionButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.videoURL] options:@{} completionHandler:nil];
}


@end
