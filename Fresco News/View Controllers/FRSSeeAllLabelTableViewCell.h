//
//  FRSSeeAllLabelTableViewCell.h
//  Fresco
//
//  Created by User on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const seeAllCellIdentifier = @"see-all-cell";
static CGFloat const seeAllCellHeight = 44;

@interface FRSSeeAllLabelTableViewCell : UITableViewCell

- (void)setLabelText:(NSString *)labelText;

@end
