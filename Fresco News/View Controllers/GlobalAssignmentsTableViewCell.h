//
//  GlobalAssignmentsTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 6/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalAssignmentsTableViewCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *assignment;
@property (strong, nonatomic) NSArray *outlets;
@property (nonatomic, copy) void (^openCameraBlock)();

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assignment:(NSArray *)assignment;
-(void)configureGlobalAssignmentCellWithAssignment:(NSDictionary *)assignment;

@end
