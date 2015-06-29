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
#import "UIView+Additions.h"

@interface GalleriesViewController()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

/*
** Index of cell that is currently playing a video
*/

@property (nonatomic, assign) NSIndexPath *playingIndex;


/*
** Check if the navigation is in the detail
*/

@property (nonatomic, assign) BOOL inDetail;

/*
** Check if the navigation is in the detail
*/

@property (nonatomic, assign) BOOL sustainDisptach;

@end

@implementation GalleriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0f;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.alpha = .54;
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.54]];
    [self.tableView addSubview:self.refreshControl];

    // YES by default, but needs to be the only such visible UIScrollView
    self.tableView.scrollsToTop = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:NO];
    
    self.inDetail = NO;
    
    self.playingIndex = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    
    [self disableVideo];


}

- (void)refresh
{
    
    if([self.parentViewController isKindOfClass:[HomeViewController class]]){
    
        [((HomeViewController *) self.parentViewController) performNecessaryFetch:nil];
        
    }
    else if([self.parentViewController isKindOfClass:[ProfileViewController class]]){
 
        [((ProfileViewController *) self.parentViewController) performNecessaryFetch:nil];
        
    }
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

- (void)disableVideo
{
    
    self.playingIndex = nil;
    
    for(GalleryTableViewCell *cell in [self.tableView visibleCells]){
        //If the player is actually playing
        if(cell.galleryView.sharedPlayer != nil){
            [cell.galleryView.sharedPlayer pause];
            cell.galleryView.sharedPlayer = nil;
            [cell.galleryView.sharedLayer removeFromSuperlayer];
        }
    }
    
}

- (void)openDetailWithGallery:(FRSGallery *)gallery{
    
    [self disableVideo];
    
    self.inDetail = true;
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GalleryTableViewCell *cell = (GalleryTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self openDetailWithGallery:cell.gallery];

}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /*
    ** Video Conditioning
    */
    
    if(self.inDetail) return;
    
    CGRect visibleRect = (CGRect){.origin = self.tableView.contentOffset, .size = self.tableView.bounds.size};
    
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    
    NSIndexPath *visibleIndexPath = [self.tableView indexPathForRowAtPoint:visiblePoint];
    
    GalleryTableViewCell *cell = (GalleryTableViewCell *) [self.tableView cellForRowAtIndexPath:visibleIndexPath];
    
    FRSPost *firstPost = cell.gallery.posts[0];
    
    //Check if the cell is a video first!
    if([firstPost isVideo]){
        
        // Video indicator, uncomment when added to cell
        //[cell.videoImage setAlpha:1];
        
        //If the video current playing isn't this one, or no video has played yet
        if((self.playingIndex != visibleIndexPath || self.playingIndex == nil)){
            
            [self disableVideo];

            self.sustainDisptach = true;
            
            //Dispatch event to make sure the condition is true for more than one second
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //If the video current playing isn't this one, or no video has played yet
                if((self.playingIndex != visibleIndexPath || self.playingIndex == nil) && cell != nil && self.sustainDisptach){
                    
                    //Check to make sure the current playing video isn't the same as the one about to play
                    if(![((AVURLAsset *)cell.galleryView.sharedPlayer.currentItem.asset).URL isEqual:firstPost.video]
                       || (AVURLAsset *)cell.galleryView.sharedPlayer == nil ){
                        
                        [self disableVideo];
                        
                        self.playingIndex = visibleIndexPath;
                        
                        // TODO: Check for missing/corrupt media at firstPost.url
                        cell.galleryView.sharedPlayer = [AVPlayer playerWithURL:firstPost.video];
                        
                        [cell.galleryView.sharedPlayer setMuted:NO];
                        
                        cell.galleryView.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:cell.galleryView.sharedPlayer];
                        
                        cell.galleryView.sharedLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        
                        cell.galleryView.sharedLayer.frame = [cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame;
                        
                        [cell.galleryView.sharedPlayer play];
                        
                        [[cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].layer addSublayer:cell.galleryView.sharedLayer];
                        
                    }
                    
                }
            
            });
            
        }

    }
    
    //If the cell doesn't have a video
    else{
        
        self.sustainDisptach = false;
        
        [self disableVideo];
        
    }
    
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
        if ([self.containingViewController isKindOfClass:[HomeViewController class]] ||
            [self.containingViewController isKindOfClass:[StoryViewController class]] ) {
            [self.viewProfileHeader removeFromSuperview];
            self.tableView.tableHeaderView = nil;
        }
        else {
            ProfileHeaderViewController *phvc = [segue destinationViewController];
            phvc.frsUser = self.frsUser;
            self.tableView.tableHeaderView.frame = phvc.view.bounds;
        }
    }
}

@end
