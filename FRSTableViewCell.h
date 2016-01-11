//
//  FRSTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FRSTableViewCell : UITableViewCell

-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes;

-(void)configureDefaultCellWithTitle:(NSString *)title withSecondTitle:(NSString *)secondTitle;

-(void)configureCellWithUsername:(NSString *)username;

-(void)configureAssignmentCell;

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag;

-(void)configureEmptyCellSpace:(BOOL)yes;

-(void)configureLogOut;

@end