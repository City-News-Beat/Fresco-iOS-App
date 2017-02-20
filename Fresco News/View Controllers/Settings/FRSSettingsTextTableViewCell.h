//
//  FRSSettingsTextTableViewCell.h
//  Fresco
//
//  Created by Maurice Wu on 2/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const settingsTextCellIdentifier = @"settings-text-cell";
static CGFloat const settingsTextCellHeight = 44;
static CGFloat const settingsTextUsernameCellHeight = 56;

@interface FRSSettingsTextTableViewCell : UITableViewCell

- (void)loadText:(NSString *)primaryText;
- (void)loadText:(NSString *)primaryText withSecondary:(NSString *)secondaryText withSecondaryColor:(UIColor *)secondaryColor;
- (void)loadText:(NSString *)primaryText withSecondary:(NSString *)secondaryText withDisclosureIndicator:(BOOL)disclosureIndicator andFont:(UIFont *)font;

@end
