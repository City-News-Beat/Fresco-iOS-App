//
//  StoriesViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/4/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoriesViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "FRSTag.h"
#import "StoryCellMosaic.h"
#import "StoryCellMosaicHeader.h"
#import "StoryViewController.h"

@interface StoriesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation StoriesViewController

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
    _stories = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFrescoImageHeader];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    
    //UINib *storyCellNib = [UINib nibWithNibName:@"FRSStoryListCell" bundle:[NSBundle mainBundle]];
    //[_collectionView registerNib:storyCellNib forCellWithReuseIdentifier:[FRSStoryListCell identifier]];
    
    [self performNecessaryFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Loading
- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getStoriesWithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            [self.stories setArray:responseObject];
        }
        [self reloadData];
    }];
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - loading view

- (void)setActivityIndicatorVisible:(BOOL)visible{
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
    return [self.stories count];
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
    
    // get story for cell at this index -- tags for now actually
    FRSStory *story = [self.stories objectAtIndex:index];
    
    StoryCellMosaic *storyCell = [tableView dequeueReusableCellWithIdentifier:[StoryCellMosaic identifier] forIndexPath:indexPath];
    
    storyCell.story = story;
    [storyCell layoutIfNeeded];
    
    return storyCell;
}


#pragma mark - UITableViewDelegate
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}
*/

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    StoryCellMosaicHeader *storyCellHeader = [tableView dequeueReusableCellWithIdentifier:[StoryCellMosaicHeader identifier]];
    
    // remember, one story per section
    FRSStory *cellStory = [self.stories objectAtIndex:section];
    [storyCellHeader populateViewWithStory:cellStory];
    
    return storyCellHeader;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showGallery"]) {
        StoryCellMosaic *storyCell = (StoryCellMosaic *)sender;
        StoryViewController *gvc = [segue destinationViewController];
        gvc.story = storyCell.story;
    }
}
@end
