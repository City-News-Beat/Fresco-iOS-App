//
//  FRSTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUser.h"
#import <CoreData/CoreData.h>

@interface FRSTableViewCell : UITableViewCell

- (void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes andRightAlignedTitle:(NSString *)secondTitle rightAlignedTitleColor:(UIColor *)color;

- (void)configureCellWithUsername:(NSString *)username;

- (void)configureAssignmentCellEnabled:(BOOL)enabled;

- (void)configureEditableCellWithDefaultText:(NSString *)string withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType;

- (void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag enabled:(BOOL)enabled;

- (void)configureCellWithRightAlignedButtonTitle:(NSString *)title withWidth:(CGFloat)width withColor:(UIColor *)color;

- (void)configureEmptyCellSpace:(BOOL)yes;

- (void)configureLogOut;

- (void)configureDisableAccountCell;
- (void)configureSliderCell;
- (void)configureMapCell;

- (void)configureSettingsHeaderCellWithTitle:(NSString *)title;

@property (strong, nonatomic) UIButton *rightAlignedButton;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UITextField *secondaryField;
@property (strong, nonatomic) UITextField *tertiaryField;
@property (strong, nonatomic) UISwitch *twitterSwitch;
@property (strong, nonatomic) NSString *twitterHandle;

@property (strong, nonatomic) UISwitch *facebookSwitch;
@property (strong, nonatomic) NSString *facebookName;
@property (nonatomic) NSInteger cellType;
@property (strong, nonatomic) NSString *representedID;
@property (weak, nonatomic) NSManagedObject *representedObject;

@property (strong, nonatomic) UITableView *parentTableView;
- (void)twitterToggle;
- (void)facebookToggle;

@end
