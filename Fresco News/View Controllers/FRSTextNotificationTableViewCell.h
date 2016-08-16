//
//  FRSTextNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSTextNotificationTableViewCell : UITableViewCell

-(void)configureCell;

@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end
