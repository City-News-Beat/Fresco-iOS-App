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
#import "FRSBaseViewController.h"
#import "FRSStoryDetailViewController.h"
#import "FRSScrollingViewController.h"

@interface FRSStoryDetailViewController : FRSScrollingViewController<UITableViewDelegate, UITableViewDataSource, FRSGalleryViewDelegate>

{
    
}

@property (nonatomic, retain) IBOutlet UITableView *galleriesTable;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, weak) FRSStory *story;
@property (nonatomic, retain) NSString *storyID;
@property (strong, nonatomic) NSString *timestamp;

-(void)reloadData;
-(void)scrollToGalleryIndex:(NSInteger)index;
-(void)configureWithGalleries:(NSArray *)galleries;
-(void)configureWithStory:(FRSStory *)story;

@end
