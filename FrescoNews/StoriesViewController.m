//
//  StoriesViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/4/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIScrollView+SVInfiniteScrolling.h>
#import "StoriesViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "FRSTag.h"
#import "StoryCellMosaic.h"
#import "StoryCellMosaicHeader.h"
#import "StoryViewController.h"
#import "FRSImage.h"

static CGFloat const kImageHeight = 96.0;
static CGFloat const kInterImageGap = 1.0f;

@interface StoriesViewController () <UITableViewDelegate, UITableViewDataSource, StoryThumbnailViewTapHandler>
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
    
    [self setFrescoNavigationBar];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 96;
    
    [self performNecessaryFetch:nil];
    
    //Endless scroll handler
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:self.stories.count];
        
        [[FRSDataManager sharedManager] getStoriesWithResponseBlock:num withReponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                [self.stories addObjectsFromArray:responseObject];
                
                [self reloadData];
                
                [self.tableView.infiniteScrollingView stopAnimating];
                
            }

        }];
                
    }];
    
    
}

#pragma mark - Data Loading
- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    
    [[FRSDataManager sharedManager] getStoriesWithResponseBlock:nil withReponseBlock:^(id responseObject, NSError *error) {
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
    
    FRSStory *story = [self.stories objectAtIndex:index];
    
    StoryCellMosaic *storyCell = [tableView dequeueReusableCellWithIdentifier:[StoryCellMosaic identifier] forIndexPath:indexPath];
    storyCell.story = story;
    storyCell.tapHandler = self;
    [storyCell configureImages];

    return storyCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width;
    FRSStory *story = self.stories[indexPath.section];
    for (FRSPost *post in story.thumbnails) {
        if (post.image.height && post.image.width) {
            CGFloat scale = kImageHeight / [post.image.height floatValue];
            CGFloat imageWidth = [post.image.width floatValue] * scale;
            width += imageWidth + kInterImageGap;
            if (width > self.view.frame.size.width) {
                return 96.0 * 2;
            }
        }
    }

    return 96.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    StoryCellMosaicHeader *storyCellHeader = [tableView dequeueReusableCellWithIdentifier:[StoryCellMosaicHeader identifier]];
    
    // remember, one story per section
    FRSStory *cellStory = [self.stories objectAtIndex:section];
    [storyCellHeader populateViewWithStory:cellStory];
    
    return storyCellHeader;
}

#pragma mark - StoryThumbnailViewTapHandler
- (void)story:(FRSStory *)story tappedAtGalleryIndex:(NSInteger)index
{
    StoryViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
    svc.story = story;
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
@end
