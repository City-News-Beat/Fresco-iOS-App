//
//  FRSDefaultNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDefaultNotificationTableViewCell.h"
#import "UIColor+Fresco.h"

@implementation FRSDefaultNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];


}

-(void)configureCell {
    
    //Configure background color
    if (self.backgroundViewColor == nil) {
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
    }
    
    
    //Configure labels and rounded image
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 0;
    self.image.backgroundColor = [UIColor frescoLightTextColor];
    self.image.layer.cornerRadius = 20;

    
    
    //Configure count annotation
    self.annotationView.layer.cornerRadius = 12;
    if (self.count <= 1) {
        self.annotationView.alpha = 0;
    } else if (self.count <= 9) {
        self.annotationLabel.text = [NSString stringWithFormat:@"+%ld", self.count];
    } else {
        self.annotationLabel.text = @"+";
    }
    
    
    
    //if cell.type == follower
    //Configure follow button
    //if following
//    [self.followButton setImage:[UIImage imageNamed:@"already-following"] forState:UIControlStateNormal];
//    self.followButton.tintColor = [UIColor frescoOrangeColor];
    //else if not following
    [self.followButton setImage:[UIImage imageNamed:@"add-follower"] forState:UIControlStateNormal];
    //Button is set to system in IB to keep default fading behavior
    //Alpha is set in the png, setting tint to black retains original alpha in png
    self.followButton.tintColor = [UIColor blackColor];

}

- (IBAction)followTapped:(id)sender {

    if ([self.followButton.imageView.image isEqual:[UIImage imageNamed:@"already-following"]]) {
        [self.followButton setImage:[UIImage imageNamed:@"add-follower"] forState:UIControlStateNormal];
        self.followButton.tintColor = [UIColor frescoOrangeColor];
    } else if ([self.followButton.imageView.image isEqual: [UIImage imageNamed:@"add-follower"]]) {
        [self.followButton setImage:[UIImage imageNamed:@"already-following"] forState:UIControlStateNormal];
        self.followButton.tintColor = [UIColor blackColor];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
