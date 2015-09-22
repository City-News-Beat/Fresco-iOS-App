//
//  StoriesViewController.m
//  FrescoNews
//
//  Created by Fresco News on 3/4/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSRootViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>
#import "StoriesViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "StoryCellMosaic.h"
#import "StoryCellMosaicHeader.h"
#import "StoryViewController.h"
#import "FRSImage.h"
#import "FRSRefreshControl.h"

static CGFloat const kImageHeight = 96.0;
static CGFloat const kInterImageGap = 1.0f;

@interface StoriesViewController () <UITableViewDelegate, UITableViewDataSource, StoryThumbnailViewTapHandler, StoryHeaderViewTapHandler>

/*
 ** Sets of images for each story
 */

@property (strong, nonatomic) NSMutableArray *imageArrays;


/*
** Scroll View's Last Content Offset, for nav bar conditioning
*/

@property (nonatomic, assign) CGFloat lastContentOffset;

/*
 ** Background on the status bar
 */

@property (nonatomic, strong) UIView  *statusBarBackground;

@property (nonatomic, assign) BOOL currentlyHidden;

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
    
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 96;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* Instantiating table view controller because of its refresh control property.
     Instead of adding refresh control as a subview, we create it then assign it
     to our table view controller's refresh control property
     */
    
    self.refreshControl = [[FRSRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];

    [self performNecessaryFetch:NO withResponseBlock:nil];
    
    __weak typeof(self) weakSelf = self;
    
    //Endless scroll handler
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:weakSelf.stories.count];
        
        [[FRSDataManager sharedManager] getStoriesWithResponseBlock:num shouldRefresh:NO withReponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                if ([responseObject count] > 0) {
                    
                    [weakSelf.stories addObjectsFromArray:responseObject];
                    
                    [weakSelf.tableView reloadData];
                    
                }
                
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                
            }
            
        }];
        
    }];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Stories"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    self.statusBarBackground = [[UIView alloc] initWithFrame:statusBarFrame];
    self.statusBarBackground.backgroundColor = [UIColor goldStatusBarColor];
    self.statusBarBackground.alpha = 0.0f;
    
    [self.view addSubview:self.statusBarBackground];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];

    self.tableView.delegate = nil;
    
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(BOOL)refresh withResponseBlock:(FRSRefreshResponseBlock)responseBlock
{
    
    [[FRSDataManager sharedManager] getStoriesWithResponseBlock:nil shouldRefresh:refresh  withReponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            
            if([self.stories count] == 0
               || ![((FRSStory *)[responseObject objectAtIndex:0]).storyID isEqualToString:((FRSStory *)[self.stories objectAtIndex:0]).storyID]
               || refresh){
            
                [self.stories setArray:responseObject];
                [self.tableView reloadData];
            
            }
        }
        
        if(responseBlock) responseBlock(YES, nil);
        
    }];

}

/*
** Selector for refresh control
*/

- (void)refresh
{
    //Force the refresh as we're manually pulling to refresh here
    [self performNecessaryFetch:YES withResponseBlock:^(BOOL success, NSError *error) {
        
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
        
    }];
    
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
    
    if(index < [self.imageArrays count])
        storyCell.imageArray = self.imageArrays[index];
    
    [storyCell configureImages];
    
    return storyCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    StoryCellMosaicHeader *storyCellHeader = [tableView dequeueReusableCellWithIdentifier:[StoryCellMosaicHeader identifier]];
    
    // remember, one story per section
    FRSStory *cellStory = [self.stories objectAtIndex:section];
    
    [storyCellHeader setStory:cellStory];
    storyCellHeader.tapHandler = self;
    
    
    return storyCellHeader;
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger index = indexPath.section;
    
    self.imageArrays[index] = [self imageArrayForStory:self.stories[index]];

    CGFloat width = 0;
    BOOL flag = NO;
    
    //Check if we should double the height
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
    
    //Return by default
    return 96.0;
}

#pragma mark - Tap Gesture Delegate Handlers

- (void)tappedStoryThumbnail:(FRSStory *)story atIndex:(NSInteger)index
{
    StoryViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
    
    svc.story = story;
    
    if([[story.thumbnails objectAtIndex:index] isKindOfClass:[FRSPost class]])
        svc.selectedGallery = ((FRSPost *)[story.thumbnails objectAtIndex:index]).galleryID;
    
    [self.navigationController pushViewController:svc animated:YES];
    
}

-(void)tappedStoryHeader:(FRSStory *)story{
    
    StoryViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
    
    svc.story = story;
    
    [self.navigationController pushViewController:svc animated:YES];
    
}

#pragma mark - Image shuffling

- (NSArray *)imageArrayForStory:(FRSStory *)story
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (FRSPost *post in story.thumbnails) {
        
        //Check if the post is valid i.e. has a parent gallery id and an URL
        if (post.image.URL && post.galleryID) {
            
            //Fall back if the image is missing it's meta width and height
            if(!post.image.width || !post.image.height){
                post.image.width = [NSNumber numberWithInteger:150];
                post.image.height = [NSNumber numberWithInteger:150];
            }
            
            [array addObject:post.image];
        }
        else {
            NSLog(@"Post ID missing URL or galery: %@", post.postID);
        }
    }
    
    return array;
}


@end