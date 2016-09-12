//
//  FRSTextNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSTextNotificationTableViewCell : UITableViewCell

-(NSInteger)heightForCell;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
