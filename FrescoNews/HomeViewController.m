//
//  HomeViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "HomeViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "GalleryHeader.h"
#import "StoryTableViewCell.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    //_posts = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setFrescoImageHeader];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0;

    [self performNecessaryFetch:nil];
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getGalleriesWithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject count])
                self.galleries = responseObject;
        }
        [self reloadData];
    }];
}

- (void)reloadData
{
  //  [[self listCollectionView] reloadData];
  //  [[self detailCollectionView] reloadData];
    [self.tableView reloadData];
}

#pragma mark - loading view

- (void)setActivityIndicatorVisible:(BOOL)visible
{
/*
    [_loadingView removeFromSuperview];
    
    [self setLoadingView:nil];
    
    if (visible) {
        UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGPoint viewCenter = [[self view] center];
        [actIndicator setCenter:viewCenter];
        [[self listCollectionView] addSubview:actIndicator];
        [actIndicator startAnimating];
        [self setLoadingView:actIndicator];
    }*/
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
