//
//  FullPageGalleryViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryViewController.h"
#import "StoryTableViewCell.h"
#import "GalleryView.h"
#import "FRSStory.h"
#import "FRSGallery.h"
#import "UIView+Additions.h"

@interface StoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation StoryViewController

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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.story.galleries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // since there is a section for every story
    // and just one story per section
    // the section will tell us the "row"
    NSUInteger index = indexPath.section;
    
    FRSGallery *gallery = [self.story.galleries objectAtIndex:index];
    
    StoryTableViewCell *storyTableViewCell = [tableView dequeueReusableCellWithIdentifier:[StoryTableViewCell identifier] forIndexPath:indexPath];
    
    storyTableViewCell.gallery = gallery;
    //[storyCell layoutIfNeeded];
    
    return storyTableViewCell;
}


#pragma mark - UITableViewDelegate
//-(CGSize)tableView:(UITableView *)tableView s
@end
