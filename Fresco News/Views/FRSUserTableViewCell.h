//
//  FRSUserTableViewCell.h
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSUser;

@interface FRSUserTableViewCell : UITableViewCell
typedef void (^ReloadBlock)();

-(void)clearCell;
-(void)configureCellWithUser:(FRSUser *)user isFollowing:(BOOL)followingUser;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) FRSUser *user;
@property ReloadBlock reloadBlock;
@end
