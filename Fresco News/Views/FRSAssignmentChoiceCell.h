//
//  FRSAssignmentChoiceCell.h
//  Fresco
//
//  Created by Daniel Sun on 12/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSAssignment;

@interface FRSAssignmentChoiceCell : UITableViewCell

@property (strong, nonatomic) FRSAssignment *assignment;
@property (nonatomic) BOOL isSelectedAssignment;


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assignment:(FRSAssignment *)assignment;
-(void)configureCell;
-(void)clearCell;

-(void)toggleImage;

@end
