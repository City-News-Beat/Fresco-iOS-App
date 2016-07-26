//
//  FRSAssignmentPickerTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 5/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSAssignment.h"

@interface FRSAssignmentPickerTableViewCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *assignment;
@property (nonatomic) BOOL isSelectedAssignment;
@property (strong, nonatomic) NSArray *outlets;
@property (strong, nonatomic) UIImageView *selectionImageView;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assignment:(NSArray *)assignment;
-(void)configureAssignmentCellForIndexPath:(NSIndexPath *)indexPath;
-(void)configureOutletCellWithOutlet:(NSDictionary *)outlet;
-(void)setIsSelectedAssignment:(BOOL)isSelectedAssignment;

@end
