//
//  FRSArticlesTableViewCell.h
//  Fresco
//
//  Created by Daniel Sun on 1/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSArticle;

@interface FRSArticlesTableViewCell : UITableViewCell

@property BOOL selectable;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier article:(FRSArticle *)article;

-(void)configureCell;

@end
