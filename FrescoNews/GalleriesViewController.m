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
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [self.tableView addSubview:self.refreshControl];

    // YES by default, but needs to be the only such visible UIScrollView
    self.tableView.scrollsToTop = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:NO];
    
    self.playingIndex = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    
    //If the player is actually playing
    if(self.playingIndex != nil){
        
        GalleryTableViewCell *cell = (GalleryTableViewCell *) [self.tableView cellForRowAtIndexPath:self.playingIndex];
       
        if(cell.galleryView.sharedPlayer != nil){
        
            //Stop the player from playing

            self.playingIndex = nil;

            [cell.galleryView.sharedPlayer pause];

            [cell.galleryView.sharedLayer removeFromSuperlayer];
           
        }
        
    }


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
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
    
    [galleryView setGallery:cell.gallery];
    
    [self.navigationController pushViewController:galleryView animated:YES];


}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /*
    ** Video Conditioning
    */
    
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
        if((self.playingIndex.row != visibleIndexPath.row || self.playingIndex == nil)){
            
            cell.galleryView.sharedPlayer = nil;
            
            [cell.galleryView.sharedLayer removeFromSuperlayer];
            
            //Dispatch event to make sure the condition is true for more than one second
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //Code to be executed on the main queue after delay
                if((self.playingIndex.row != visibleIndexPath.row || self.playingIndex == nil) && cell != nil){
                    
                    self.playingIndex = visibleIndexPath;
                    
                    [cell.galleryView.sharedLayer removeFromSuperlayer];
                    
                    cell.galleryView.sharedPlayer = nil;

                    // TODO: Check for missing/corrupt media at firstPost.url
                    cell.galleryView.sharedPlayer = [AVPlayer playerWithURL:firstPost.video];
                    
                    [cell.galleryView.sharedPlayer setMuted:YES];

                    cell.galleryView.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:cell.galleryView.sharedPlayer];
                    
                    cell.galleryView.sharedLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    
                    cell.galleryView.sharedLayer.frame = [cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame;
                    
                    [cell.galleryView.sharedPlayer play];
                    
                    [[cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].layer addSublayer:cell.galleryView.sharedLayer];
                    
                }
                
            });
            
        }
        
    }
    
    //If the cell doesn't have a video
    else{
        
        if(self.playingIndex != nil){
        
            GalleryTableViewCell *playingCell = (GalleryTableViewCell *) [self.tableView cellForRowAtIndexPath:self.playingIndex];

            //If the player is actually playing
            if(playingCell.galleryView.sharedPlayer != nil){
                
                //Stop the player from playing
                
                self.playingIndex = nil;
                
                [playingCell.galleryView.sharedPlayer pause];
                
                [playingCell.galleryView.sharedLayer removeFromSuperlayer];
                
            }
            
        }
        
    }
    
}


#pragma mark - Gallery Table View Cell Delegate

- (void)readMoreTapped:(FRSGallery *)gallery{

    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
    
    [galleryView setGallery:gallery];
    
    [self.navigationController pushViewController:galleryView animated:YES];

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
