//
//  FRSSplitTableView.h
//  Fresco
//
//  Created by Philip Bernstein on 6/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSSplitTableView : UIScrollView
@property (nonatomic, weak) UITableView *primaryTableView;
@property (nonatomic, weak) UITableView *secondaryTableView;
@end
