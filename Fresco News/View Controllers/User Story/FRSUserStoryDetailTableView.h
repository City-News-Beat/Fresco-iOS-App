//
//  FRSUserStoryDetailTableView.h
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUserStory+CoreDataProperties.h"
#import "FRSComment.h"

@protocol FRSUserStoryDetailTableViewDelegate <NSObject>

- (void)reportComment:(FRSComment *)comment;

@end

@interface FRSUserStoryDetailTableView : UITableView

@property (weak, nonatomic) NSObject <FRSUserStoryDetailTableViewDelegate> *delegate;

- (instancetype)initWithFrame:(CGRect)frame userStory:(FRSUserStory *)userStory;

@end
