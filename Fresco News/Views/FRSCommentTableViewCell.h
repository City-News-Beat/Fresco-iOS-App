//
//  FRSCommentTableViewCell.h
//  Fresco
//
//  Created by Daniel Sun on 1/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSCommentTableViewCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier comment:(id)comment;

-(void)configureCell;

-(void)clearCell;

@end
