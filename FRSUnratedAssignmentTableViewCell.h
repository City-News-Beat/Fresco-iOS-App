//
//  FRSUnratedAssignmentTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 7/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSUnratedAssignmentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *outletLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *assignmentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@end
