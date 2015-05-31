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
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>

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
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0f;
    
    //Pull to refresh handler
    [self.tableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        [((HomeViewController *) self.parentViewController) performNecessaryFetch:nil];
        
        [self.tableView.pullToRefreshView stopAnimating];
    }];
    
    //Endless scroll handler
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:[[self galleries] count]];
        
        _isRunning = true;
        
        //Make request for more posts, append to galleries array
        [[FRSDataManager sharedManager] getHomeDataWithResponseBlock:num responseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                if ([responseObject count]) {
                    
                    [self.galleries addObjectsFromArray:responseObject];
                    
                    [self refresh];
                    
                    _isRunning = false;
                    
                }
            }
            [[self tableView] reloadData];
        }];

        [self.tableView.infiniteScrollingView stopAnimating];
        
    }];
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // remember, one story per section
    FRSGallery *gallery = [self.galleries objectAtIndex:indexPath.row];
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
    
    [galleryView setGallery:gallery];
    
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
        if((_playingIndex.row != visibleIndexPath.row || _playingIndex == nil)){
            
            cell.galleryView.sharedPlayer = nil;
            
            [cell.galleryView.sharedLayer removeFromSuperlayer];
            
            //Dispatch event to make sure the condition is true for more than one second
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //Code to be executed on the main queue after delay
                if((_playingIndex.row != visibleIndexPath.row || _playingIndex == nil) && cell != nil){
                    
                    self.playingIndex = visibleIndexPath;
                    
                    [cell.galleryView.sharedLayer removeFromSuperlayer];
                    
                    cell.galleryView.sharedPlayer = nil;
                    
                    cell.galleryView.sharedPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:firstPost.mediaURLString]];
                    
                    [cell.galleryView.sharedPlayer setMuted:YES];
                    
                    cell.galleryView.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:cell.galleryView.sharedPlayer];
                    
                    cell.galleryView.sharedLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    
                    cell.galleryView.sharedLayer.frame = [cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame;
                    
                    [cell.galleryView.sharedPlayer play];
                    
                    [[cell.galleryView.collectionPosts cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].layer addSublayer:cell.galleryView.sharedLayer];
                    
                    //Pulsing Animation for video image, uncomment if wished to be implemented
                    
//                    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//                    
//                    pulseAnimation.duration = .4;
//                    
//                    pulseAnimation.toValue = [NSNumber numberWithFloat:1.2];
//                    
//                    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//                    
//                    pulseAnimation.autoreverses = YES;
//                    
//                    pulseAnimation.repeatCount = FLT_MAX;
//                    
//                    [cell.videoImage.layer addAnimation:pulseAnimation forKey:nil];
//                    
//                    [UIView animateWithDuration:0.5
//                                          delay:1
//                                        options:UIViewAnimationOptionCurveEaseInOut
//                                     animations:^{
//                                         [cell.videoImage setAlpha:0];
//                                     } completion:^(BOOL finished) {
//                                         [cell.videoImage.layer removeAllAnimations];
//                                     }];
                    
                }
                
            });
            
        }
        
    }
    
    //If the cell doesn't have a video
    else{
        
        //If the player is actually playing
        if(cell.galleryView.sharedPlayer != nil){
            
            //Stop the player from playing
            
            _playingIndex = nil;
            
            [cell.galleryView.sharedPlayer pause];
            
            [cell.galleryView.sharedLayer removeFromSuperlayer];
            
        }
        
    }
    
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