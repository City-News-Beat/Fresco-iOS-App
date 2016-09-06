//
//  FRSTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSTableViewCellDelegate <NSObject>

-(void)reloadDataDelegate;

@end


@interface FRSTableViewCell : UITableViewCell

@property (weak, nonatomic) NSObject <FRSTableViewCellDelegate> *delegate;

-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes andRightAlignedTitle:(NSString *)secondTitle;

-(void)configureCellWithUsername:(NSString *)username;

-(void)configureAssignmentCellEnabled:(BOOL)enabled;

-(void)configureEditableCellWithDefaultText:(NSString *)string withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType;

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag enabled:(BOOL)enabled;

-(void)configureCellWithRightAlignedButtonTitle:(NSString *)title withWidth:(CGFloat)width withColor:(UIColor *)color;

-(void)configureEmptyCellSpace:(BOOL)yes;

-(void)configureLogOut;

-(void)configureCheckBoxCellWithTitle:(NSString *)title withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSelected:(BOOL)isSelected;
-(void)configureEditableCellWithDefaultTextWithMultipleFields:(NSArray *)titles withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType;
-(void)configureDisableAccountCell;
-(void)configureSliderCell;
-(void)configureMapCell;

-(void)configureSettingsHeaderCellWithTitle:(NSString *)title;
-(void)configureSearchSeeAllCellWithTitle:(NSString *)title;
-(void)configureSearchUserCellWithProfilePhoto:(NSURL *)profile fullName:(NSString *)nameString userName:(NSString *)username isFollowing:(BOOL)isFollowing userDict:(NSDictionary *)userDict user:(FRSUser *)user;
-(void)configureSearchStoryCellWithStoryPhoto:(NSURL *)storyPhoto storyName:(NSString *)nameString;

-(void)configureFindFriendsCell;

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
-(void)twitterToggle;
-(void)facebookToggle;

@end

