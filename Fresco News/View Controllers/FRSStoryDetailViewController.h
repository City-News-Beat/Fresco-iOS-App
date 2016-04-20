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
#import "UIFont+Fresco.h"
#import "FRSGalleryView.h"

//<<<<<<< HEAD
@interface FRSStoryDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, FRSGalleryViewDelegate>
//=======
//@interface FRSStoryDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
//>>>>>>> 3.0-omar
{
    
}

@property (nonatomic, retain) IBOutlet UITableView *galleriesTable;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, weak) FRSStory *story;

-(void)reloadData;
-(void)scrollToGalleryIndex:(NSInteger)index;
@end
