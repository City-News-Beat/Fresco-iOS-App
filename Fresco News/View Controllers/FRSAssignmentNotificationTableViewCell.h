//
//  FRSAssignmentNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSExternalNavigationDelegate <NSObject>

-(void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

@end

@interface FRSAssignmentNotificationTableViewCell : UITableViewCell

@property (nonatomic, retain) id<FRSExternalNavigationDelegate> delegate;

-(void)configureAssignmentCellWithID:(NSString *)assignmentID;
-(void)configureCameraCellWithAssignmentID:(NSString *)assignmentID;
-(NSInteger)heightForCell;

@end
