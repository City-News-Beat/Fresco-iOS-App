//
//  FRSStoryDetailViewController.h
//  Fresco
//
//  Created by Philip Bernstein on 3/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fresco.h"
#import "UIColor+Fresco.h"

@interface FRSStoryDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet UITableView *galleriesTable;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, weak) FRSStory *story;

-(void)reloadData;
@end
