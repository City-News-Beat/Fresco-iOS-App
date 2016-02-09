//
//  FRSUserTableViewCell.h
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSUserTableViewCell : UITableViewCell

-(void)clearCell;
-(void)configureCellWithUser:(FRSUser *)user;

@end
