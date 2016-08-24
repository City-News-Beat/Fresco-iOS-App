//
//  FRSCommentCell.h
//  Fresco
//
//  Created by Philip Bernstein on 8/24/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface FRSCommentCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIImageView *profilePicture;
@property (nonatomic, retain) IBOutlet TTTAttributedLabel *commentTextField;
@end
