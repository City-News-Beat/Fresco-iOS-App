//
//  FullPageGalleryViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ProfileViewController.h"
#import "StoryTableViewCell.h"
#import "GalleryView.h"
#import "FRSDataManager.h"
#import "FRSStory.h"
#import "FRSGallery.h"
#import "FRSTag.h"
#import "UIView+Additions.h"
#import "GalleryHeader.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation ProfileViewController

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
    self.profileView.backgroundColor = [UIColor colorWithHex:@"FAFAFA"];
    self.profileWrapperView.backgroundColor = [UIColor colorWithHex:@"FAFAFA"];
    
    [self performNecessaryFetch:nil];
}

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getGalleriesWithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject count])
            self.galleries = responseObject;
        }
        [self reloadData];
    }];
    
    [[FRSDataManager sharedManager] getPostsWithTag:self.tag limit:@(self.posts.count) responseBlock:^(NSArray *responseObject, NSError *error) {
        if (!error) {
            [self.posts setArray:responseObject];
            [self reloadData];
            // [self.refreshControl endRefreshing];
            // [[self listCollectionView] setContentOffset:CGPointZero animated:YES];
        }
    }];
    
    
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.galleries count];
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
    
    FRSGallery *gallery = [self.galleries objectAtIndex:index];
    
    StoryTableViewCell *storyTableViewCell = [tableView dequeueReusableCellWithIdentifier:[StoryTableViewCell identifier] forIndexPath:indexPath];
    
    storyTableViewCell.gallery = gallery;
    //[storyCell layoutIfNeeded];
    
    return storyTableViewCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GalleryHeader *storyCellHeader = [tableView dequeueReusableCellWithIdentifier:[GalleryHeader identifier]];
    
    // remember, one story per section
    FRSGallery *gallery = [self.galleries objectAtIndex:section];
    [storyCellHeader setGallery:gallery];
    
    return storyCellHeader;
}

@end
