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

-(void)configureEditableCellWithDefaultText:(NSString *)string withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure;

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag;

-(void)configureCellWithRightAlignedButtonTitle:(NSString *)title withWidth:(CGFloat)width;

-(void)configureEmptyCellSpace:(BOOL)yes;

-(void)configureLogOut;

-(void)configureCheckBoxCellWithTitle:(NSString *)title withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSelected:(BOOL)isSelected;

-(void)configureDisableAccountCell;


@end

