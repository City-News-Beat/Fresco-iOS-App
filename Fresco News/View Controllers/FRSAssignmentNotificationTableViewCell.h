//
//  FRSAssignmentNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSAssignmentNotificationTableViewCell : UITableViewCell

-(void)configureAssignmentCellWithID:(NSString *)assignmentID;
-(void)configureCameraCellWithAssignmentID:(NSString *)assignmentID;

@end
