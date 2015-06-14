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
@property (strong, nonatomic) NSMutableArray *imageArrays;
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
    _imageArrays = [[NSMutableArray alloc] init];
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
    storyCell.imageArray = self.imageArrays[index];
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
    NSUInteger index = indexPath.section;
    self.imageArrays[index] = [self imageArrayForStory:self.stories[index]];

    CGFloat width;
    BOOL flag = NO;
    for (FRSImage *image in self.imageArrays[index]) {
        if (flag) {
            return 96.0 * 2;
        }

        CGFloat scale = kImageHeight / [image.height floatValue];
        CGFloat imageWidth = [image.width floatValue] * scale;
        width += imageWidth + kInterImageGap;
        if (width > self.view.frame.size.width) {
            flag = YES; // Return 192.0 on next iteration, if there is one
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

#pragma mark - Image shuffling

- (NSArray *)imageArrayForStory:(FRSStory *)story
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];

    for (FRSPost *post in story.thumbnails) {
        // this finds cleaner data
        if (post.image.height && post.image.width) {
            [array addObject:post.image];
        }
    }

    return [self shuffle:array];
}

- (NSArray *)shuffle:(NSMutableArray *)array
{
    // seeding the random number generator with a constant
    // will make the images come out the same every time which is an optimization
    srand(42);
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + (rand() % remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }

    return [array copy];
}

@end
