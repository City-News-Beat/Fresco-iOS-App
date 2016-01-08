//
//  FRSTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSUInteger, FRSSettingCellType) {
//    FRSSettingCellTypeDefault = 0,
//    FRSSettingCellTypeLarge,
//    FRSSettingCellTypeSocial,
//};


@interface FRSTableViewCell : UITableViewCell

//@property (nonatomic) FRSSettingCellType cellType;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes;

-(void)configureDefaultCellWithTitle:(NSString *)title withSecondTitle:(NSString *)secondTitle;

-(void)configureCellWithUsername:(NSString *)username;

-(void)configureAssignmentCell;

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag;

-(void)configureEmptyCellSpace;

-(void)configureLogOut;

@end