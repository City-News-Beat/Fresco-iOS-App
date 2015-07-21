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

static CGFloat const kImageHeight = 96.0;
static CGFloat const kInterImageGap = 1.0f;

@interface StoriesViewController () <UITableViewDelegate, UITableViewDataSource, StoryThumbnailViewTapHandler, StoryHeaderViewTapHandler>

/*
** Sets of images for each story
*/

@property (strong, nonatomic) NSMutableArray *imageArrays;

/*
** Refresh control for table view
*/

@property (nonatomic, strong) UIRefreshControl *refreshControl;

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 96;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.alpha = .54;
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [self.tableView addSubview:self.refreshControl];
    
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
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Stories"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    self.statusBarBackground = [[UIView alloc] initWithFrame:statusBarFrame];
    self.statusBarBackground.backgroundColor = [UIColor colorWithHex:@"ffc100"];
    self.statusBarBackground.alpha = 0.0f;
    
    [self.view addSubview:self.statusBarBackground];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    self.tableView.delegate = self;
    
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [self resetNavigationandTabBar];
    
    self.tableView.delegate = nil;

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

- (void)refresh
{
    [self performNecessaryFetch:nil];
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

- (void)reloadData
{
    [self.tableView reloadData];
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

#pragma mark - Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    /*
    ** Navigation Bar Conditioning
    */

    if (self.lastContentOffset > scrollView.contentOffset.y && ( (fabs(scrollView.contentOffset.y  - self.lastContentOffset) > 200) || scrollView.contentOffset.y <=0)){
        
        //SHOW
        if(self.navigationController.navigationBar.hidden == YES  && self.currentlyHidden){
            
            //Resets elements back to normal state
            [self resetNavigationandTabBar];
            
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
        
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 100){
        
        //HIDE
        if(self.navigationController.navigationBar.hidden == NO && !self.currentlyHidden){
            
            self.currentlyHidden = YES;
            
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            
            [UIView animateWithDuration:.1 animations:^{
                self.statusBarBackground.alpha = 1.0f;
            }];
            
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

            [((FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController) hideTabBar];
            
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
        
    }

}

-(void)resetNavigationandTabBar{
    
    self.currentlyHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    [UIView animateWithDuration:.1 animations:^{
        self.statusBarBackground.alpha = 0.0f;
    }];
    
    [((FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController) showTabBar];
    
}

#pragma mark - Tap Gesture Delegate Handlers

- (void)tappedStoryThumbnail:(FRSStory *)story atIndex:(NSInteger)index
{
    StoryViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
    
    svc.story = story;

    svc.selectedThumbnail = index;
    
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
        if (post.image.height && post.image.width && post.image.URL) {
            [array addObject:post.image];
        }
        else {
            NSLog(@"Post ID missing image, height, and/or width: %@", post.postID);
        }
    }

    return array;
}


@end
