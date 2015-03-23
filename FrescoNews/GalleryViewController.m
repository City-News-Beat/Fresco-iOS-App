//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryView.h"
#import "FRSStory.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
 //   _stories = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.galleryView.labelCaption.text = self.story.caption;
    
    /*
    UINib *galleryViewNib = [UINib nibWithNibName:@"GalleryView" bundle:[NSBundle mainBundle]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    
    //UINib *storyCellNib = [UINib nibWithNibName:@"FRSStoryListCell" bundle:[NSBundle mainBundle]];
    //[_collectionView registerNib:storyCellNib forCellWithReuseIdentifier:[FRSStoryListCell identifier]];
    
    [self performNecessaryFetch:nil];
     */
}
@end
