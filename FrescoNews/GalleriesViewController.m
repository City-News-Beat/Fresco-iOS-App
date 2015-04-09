//
//  GalleriesViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleriesViewController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "GalleryTableViewCell.h"
#import "GalleryHeader.h"
#import "FRSDataManager.h"
#import "FRSStory.h"
#import "FRSGallery.h"
#import "UIView+Additions.h"


@interface GalleriesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewProfileHeader;
@end

@implementation GalleriesViewController

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

- (void)refresh
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
    
    GalleryTableViewCell *galleryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[GalleryTableViewCell identifier] forIndexPath:indexPath];
    
    galleryTableViewCell.gallery = gallery;
    
    return galleryTableViewCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GalleryHeader *galleryHeader = [tableView dequeueReusableCellWithIdentifier:[GalleryHeader identifier]];
    
    // remember, one story per section
    FRSGallery *gallery = [self.galleries objectAtIndex:section];
    galleryHeader.gallery = gallery;
    
    return galleryHeader;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"embedProfileHeader"]) {
        if ([self.containingViewController isKindOfClass:[HomeViewController class]])
            [self.viewProfileHeader removeFromSuperview];
    }
}
@end
