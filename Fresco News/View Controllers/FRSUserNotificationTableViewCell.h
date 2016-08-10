//
//  FRSUserNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSUserNotificationTableViewCell : UITableViewCell

@property CGFloat height;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)configureDefaultCellWithNotificationTitle:(NSString *)title notificationBody:(NSString *)body;


@end
