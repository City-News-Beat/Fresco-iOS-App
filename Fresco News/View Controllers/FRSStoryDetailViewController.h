//
//  FRSStoryDetailViewController.h
//  Fresco
//
//  Created by Philip Bernstein on 3/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Fresco.h"

@interface FRSStoryDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet UITableView *galleriesTable;
@property (nonatomic, weak) NSArray *stories;

-(void)reloadData;
@end
