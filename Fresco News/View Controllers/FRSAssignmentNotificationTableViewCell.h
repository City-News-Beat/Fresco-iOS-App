//
//  FRSAssignmentNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSExternalNavigationDelegate <NSObject>

- (void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

@end

@interface FRSAssignmentNotificationTableViewCell : UITableViewCell

@property (nonatomic, retain) id<FRSExternalNavigationDelegate> delegate;

- (NSInteger)heightForCell;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (nonatomic, retain) NSString *assignmentID;

@end
