//
//  GalleriesViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSRootViewController.h"
#import "GalleriesViewController.h"
#import "HighlightsViewController.h"
#import "ProfileViewController.h"
#import "StoryViewController.h"
#import "ProfileHeaderViewController.h"
#import "GalleryTableViewCell.h"
#import "GalleryHeader.h"
#import "FRSDataManager.h"
#import "FRSStory.h"
#import "FRSGallery.h"
#import "GalleryView.h"
#import "GalleryViewController.h"
#import "FRSPost.h"
#import "PostCollectionViewCell.h"

@interface GalleriesViewController()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

/*
 ** Index of cell that is currently playing a video
 */

@property (nonatomic, assign) NSIndexPath *playingIndex;


/*
 ** Check if the navigation is in the detail
 */

@property (nonatomic, assign) NSIndexPath *dispatchIndex;

/*
 ** Scroll View's Last Content Offset, for nav bar conditioning
 */

@property (nonatomic, assign) CGFloat lastContentOffset;

/*
 ** Background on the status bar
 */

@property (nonatomic, strong) UIView  *statusBarBackground;


@end

@implementation GalleriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Table View Setup */
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0f;
    
    /* Refresh Control Setup */
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    self.refreshControl.alpha = .54;
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.54]];
    [self.tableView addSubview:self.refreshControl];
    
    // YES by default, but needs to be the only such visible UIScrollView
    self.tableView.scrollsToTop = YES;

    /* Set up status bar background for nav/tab slide away */
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    self.statusBarBackground = [[UIView alloc] initWithFrame:statusBarFrame];
    self.statusBarBackground.backgroundColor = [UIColor colorWithHex:@"ffc100"];
    self.statusBarBackground.alpha = 0.0f;
    
    [self.view addSubview:self.statusBarBackground];
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //Reset playing index for a fresh load
    self.playingIndex = nil;
    
    //Set delegate, reset in `viewWillDisappear`
    self.tableView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    //Slide back up
    [self resetNavigationandTabBar];
    
    //Turn off any video
    [self disableVideo];
    
    //Disable delegate, turned back on in `viewDidAppear`
    self.tableView.delegate = nil;
    
}

- (void)refresh
{
    
    if([self.parentViewController isKindOfClass:[HighlightsViewController class]]){
        
        [((HighlightsViewController *) self.parentViewController) performNecessaryFetch:nil];
        
    }
    else if([self.parentViewController isKindOfClass:[ProfileViewController class]]){
        
        [((ProfileViewController *) self.parentViewController) performNecessaryFetch:nil];
        
        [self.profileHeaderViewController updateUserInfo];
        
    }
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

/*
 ** Disable any playing video
 */

- (void)disableVideo{
    
    self.playingIndex = nil;
    
    self.dispatchIndex = nil;
    
    for(GalleryTableViewCell *cell in [self.tableView visibleCells]){
        //If the player is actually playing
        if(cell.galleryView.sharedPlayer != nil){
            [cell.galleryView.sharedLayer removeFromSuperlayer];
            [cell.galleryView.sharedPlayer pause];
            cell.galleryView.sharedPlayer = nil;
        }
    }
    
}

/*
 ** Open gallery detail view
 */

- (void)openDetailWithGallery:(FRSGallery *)gallery{
    
    [self disableVideo];
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    GalleryViewController *galleryViewController = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
    
    [galleryViewController setGallery:gallery];
    
    [self.navigationController pushViewController:galleryViewController animated:YES];
    
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
    
    galleryTableViewCell.galleryTableViewCellDelegate = self;
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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {

    /*
    ** Navigation Bar Conditioning
    */

    if (self.lastContentOffset > scrollView.contentOffset.y && ( (fabs(scrollView.contentOffset.y  - self.lastContentOffset) > 200) || scrollView.contentOffset.y <=0)){
        
        //SHOW
        if(self.navigationController.navigationBar.hidden == YES  && self.currentlyHidden){
            
            self.currentlyHidden = NO;
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            
            [UIView animateWithDuration:.1 animations:^{
                self.statusBarBackground.alpha = 0.0f;
            }];
            
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
            
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
        
    }
    
    
    /*
    ** Video Conditioning
    */
    
    //Make sure we're in the parent view controller, not the detail view
    if(![[self.navigationController visibleViewController] isKindOfClass:[HighlightsViewController class]] &&
       ![[self.navigationController visibleViewController] isKindOfClass:[ProfileViewController class]]){
        return;
    }
    
    CGRect visibleRect = (CGRect){.origin = self.tableView.contentOffset, .size = self.tableView.bounds.size};
    
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    
    NSIndexPath *visibleIndexPath = [self.tableView indexPathForRowAtPoint:visiblePoint];
    
    GalleryTableViewCell *cell = (GalleryTableViewCell *) [self.tableView cellForRowAtIndexPath:visibleIndexPath];
    
    FRSPost *post = cell.gallery.posts[0];
    
    //Check if the cell is a video first!
    if([post isVideo]){
        
        PostCollectionViewCell *postCell = (PostCollectionViewCell *)[cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        //If the video current playing isn't this one, or no video has played yet
        if(self.playingIndex != visibleIndexPath || self.playingIndex == nil){
            
            [self disableVideo];
            
            self.dispatchIndex = visibleIndexPath;
            
            [postCell.videoIndicatorView startAnimating];
            
            [UIView animateWithDuration:1.0 animations:^{
                postCell.videoIndicatorView.alpha = 1.0f;
            }];
            
            //Dispatch event to make sure the condition is true for more than one second
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //If the video current playing isn't this one, or no video has played yet
                if((self.playingIndex != visibleIndexPath || self.playingIndex == nil) && cell != nil && self.dispatchIndex == visibleIndexPath){
                    
                    [self disableVideo];
                    
                    self.playingIndex = visibleIndexPath;
                    
                    // TODO: Check for missing/corrupt media at firstPost.url
                    cell.galleryView.sharedPlayer = [AVPlayer playerWithURL:post.video];
                    
                    [cell.galleryView.sharedPlayer setMuted:NO];
                    
                    cell.galleryView.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                    
                    cell.galleryView.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:cell.galleryView.sharedPlayer];
                    
                    cell.galleryView.sharedLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    
                    cell.galleryView.sharedLayer.frame = [cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame;
                    
                    [cell.galleryView.sharedPlayer play];
                    
                    postCell.processingVideo = false;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (cell.galleryView.sharedPlayer.rate > 0 && !cell.galleryView.sharedPlayer.error) {
                            
                            // player is playing
                            [UIView animateWithDuration:0.7f animations:^{
                                postCell.videoIndicatorView.alpha = 0.0f;
                            } completion:^(BOOL finished){
                                [postCell.layer addSublayer:cell.galleryView.sharedLayer];
                                postCell.videoIndicatorView.hidden = YES;
                                [postCell.videoIndicatorView stopAnimating];
                            }];
                            
                        }
                        
                    });
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(playerItemDidReachEnd:)
                                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                                               object:[cell.galleryView.sharedPlayer currentItem]];
                    
                    
                    
                }
                
            });
            
        }
        
    }
    //If the cell doesn't have a video
    else{
        
        self.dispatchIndex = nil;
        
        [self disableVideo];
        
    }
    
}

-(void)resetNavigationandTabBar{
    
    self.currentlyHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [UIView animateWithDuration:.1 animations:^{
        self.statusBarBackground.alpha = 0.0f;

    }];
    
}

#pragma mark - Video Notifier

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [(AVPlayerItem *)[notification object] seekToTime:kCMTimeZero];
    
}


#pragma mark - Gallery Table View Cell Delegate

- (void)readMoreTapped:(FRSGallery *)gallery{
    
    [self openDetailWithGallery:gallery];
    
}

- (void)shareTapped:(FRSGallery *)gallery{
    
    NSString *string = [NSString stringWithFormat:@"http://fresconews.com/gallery/%@", gallery.galleryID];
    NSURL *URL = [NSURL URLWithString:string];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                              // ...
                                          }];
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"embedProfileHeader"]) {
        if ([self.containingViewController isKindOfClass:[HighlightsViewController class]] ||
            [self.containingViewController isKindOfClass:[StoryViewController class]] ) {
            [self.viewProfileHeader removeFromSuperview];
            self.tableView.tableHeaderView = nil;
        }
        else {
            ProfileHeaderViewController *phvc = [segue destinationViewController];
            self.profileHeaderViewController = phvc;
            self.tableView.tableHeaderView.frame = phvc.view.bounds;
        }
    }
}

@end
