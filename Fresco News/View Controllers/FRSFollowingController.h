//
//  FRSFollowingController.h
//  Fresco
//
//  Created by Philip Bernstein on 6/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSFollowingController : NSObject <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, retain) NSArray *feed;
@end
