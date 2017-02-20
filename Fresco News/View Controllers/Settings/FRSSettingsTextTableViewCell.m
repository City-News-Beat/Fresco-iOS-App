//
//  FRSSettingsTextTableViewCell.m
//  Fresco
//
//  Created by Maurice Wu on 2/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSettingsTextTableViewCell.h"

@interface FRSSettingsTextTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *primaryTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondTextLabel;

@end

@implementation FRSSettingsTextTableViewCell

- (void)loadText:(NSString *)primaryText {
    [self loadText:primaryText withSecondary:nil withDisclosureIndicator:YES andFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
}

- (void)loadText:(NSString *)primaryText withSecondary:(NSString *)secondaryText withSecondaryColor:(UIColor *)secondaryColor {
    [self loadText:primaryText withSecondary:secondaryText withSecondaryColor:secondaryColor withDisclosureIndicator:YES andFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
}

- (void)loadText:(NSString *)primaryText withSecondary:(NSString *)secondaryText withDisclosureIndicator:(BOOL)disclosureIndicator andFont:(UIFont *)font {
    [self loadText:primaryText withSecondary:secondaryText withSecondaryColor:nil withDisclosureIndicator:disclosureIndicator andFont:font];
}

- (void)loadText:(NSString *)primaryText withSecondary:(NSString *)secondaryText withSecondaryColor:(UIColor *)secondaryColor withDisclosureIndicator:(BOOL)disclosureIndicator andFont:(UIFont *)font {
    self.primaryTextLabel.text = primaryText;
    self.primaryTextLabel.font = font;
    
    if (secondaryText) {
        self.secondTextLabel.text = secondaryText;
        self.secondTextLabel.hidden = NO;
    }
    else {
        self.secondTextLabel.hidden = YES;
    }
    
    if (secondaryColor) {
        self.secondTextLabel.textColor = secondaryColor;
    }
    
    if (disclosureIndicator) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}


@end
