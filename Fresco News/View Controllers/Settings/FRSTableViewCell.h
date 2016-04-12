//
//  FRSTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FRSTableViewCell : UITableViewCell

-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes andRightAlignedTitle:(NSString *)secondTitle;

-(void)configureCellWithUsername:(NSString *)username;

-(void)configureAssignmentCell;

-(void)configureEditableCellWithDefaultText:(NSString *)string withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType;

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag;

-(void)configureCellWithRightAlignedButtonTitle:(NSString *)title withWidth:(CGFloat)width withColor:(UIColor *)color;

-(void)configureEmptyCellSpace:(BOOL)yes;

-(void)configureLogOut;

-(void)configureCheckBoxCellWithTitle:(NSString *)title withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSelected:(BOOL)isSelected;

-(void)configureDisableAccountCell;
-(void)configureSliderCell;
-(void)configureMapCell;

-(void)configureSettingsHeaderCellWithTitle:(NSString *)title;
-(void)configureSearchSeeAllCellWithTitle:(NSString *)title;
-(void)configureSearchUserCellWithProfilePhoto:(UIImage *)profile fullName:(NSString *)firstName userName:(NSString *)username isFollowing:(BOOL)isFollowing;
-(void)configureSearchStoryCellWithStoryPhoto:(UIImage *)storyPhoto storyName:(NSString *)nameString;

-(void)configureFindFriendsCell;

@end

