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
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "FRSRefreshControl.h"

@interface GalleriesViewController ()

/*
** Index of cell that is currently playing a video
*/

@property (nonatomic, strong) NSIndexPath *playingIndex;

/*
** Check if the navigation is in the detail
*/

@property (nonatomic, strong) NSIndexPath *dispatchIndex;

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


-(instancetype)init {
    if (self = [super init])  {
        self.refreshDisabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Table View Setup */
    self.tableView.estimatedRowHeight = 400.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    /* Refresh Control Setup */
    if(!_refreshDisabled){
        self.refreshControl = [[FRSRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //Reset playing index for a fresh load
    self.playingIndex = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    //Turn off any video
    [self disableVideo];
    
}

- (void)refresh
{
    [self.refreshControl beginRefreshing];

    if([self.parentViewController isKindOfClass:[HighlightsViewController class]]){
        
        [((HighlightsViewController *) self.parentViewController) performNecessaryFetchWithRefresh:YES withResponseBlock:^(BOOL success, NSError *error) {
            
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
        }];
        
    }
    else if([self.parentViewController isKindOfClass:[ProfileViewController class]]){
        
        [((ProfileViewController *) self.parentViewController) performNecessaryFetch:YES withResponseBlock:^(BOOL success, NSError *error) {

            [self.profileHeaderViewController updateUserInfo];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
        }];
        
    }

}

/**
 *  Disable any playing video
 */

- (void)disableVideo{
    
    if(!self.playingIndex && !self.dispatchIndex)
        return;
    
    self.playingIndex = nil;
    
    self.dispatchIndex = nil;
    
    for(GalleryTableViewCell *cell in [self.tableView visibleCells]){
        [cell.galleryView cleanUpVideoPlayer];
    }

}

/**
 *  Open gallery detail view
 *
 *  @param gallery FRSGallery to open to
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
    FRSGallery *gallery = [self.galleries objectAtIndex:indexPath.section];
    
    GalleryTableViewCell *galleryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[GalleryTableViewCell identifier] forIndexPath:indexPath];
    
    galleryTableViewCell.galleryTableViewCellDelegate = self;
    galleryTableViewCell.gallery = gallery;
    
    return galleryTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    GalleryHeader *galleryHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[GalleryHeader identifier]];
    
    if(galleryHeader == nil){
    
        galleryHeader =  [[GalleryHeader alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.rowHeight)];
        
    }
    
    galleryHeader.gallery = [self.galleries objectAtIndex:section];
    
    return galleryHeader;
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [super scrollViewDidScroll:scrollView];
    
    [self checkForVideo];

}

#pragma mark - Video Conditioning

/*
** Video Conditioning
*/

- (void)checkForVideo{
    
    //Make sure we're in the parent view controller, not the detail view
    if(![[self.navigationController visibleViewController] isKindOfClass:[HighlightsViewController class]]
       &&
       ![[self.navigationController visibleViewController] isKindOfClass:[ProfileViewController class]]
       &&
       ![[self.navigationController visibleViewController] isKindOfClass:[StoryViewController class]]
       ){
        return;
    }

    CGRect visibleRect = (CGRect){.origin = self.tableView.contentOffset, .size = self.tableView.bounds.size};

    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));

    NSIndexPath *visibleIndexPath = [self.tableView indexPathForRowAtPoint:visiblePoint];

    GalleryTableViewCell *cell = (GalleryTableViewCell *) [self.tableView cellForRowAtIndexPath:visibleIndexPath];

    NSIndexPath *visiblePostPath;

    //Loop through and grab the visible cell
    for (PostCollectionViewCell *postCell in [cell.galleryView.collectionPosts visibleCells]) {
        
        //Check if it has a video, if it doesn't set the path to nil and break the loop
        if(![postCell.post isVideo]){
            
            visiblePostPath = nil;
            
            break;
            
        }
        //Otherwise set the visiblePosth path to the visible cell with a video
        else
            visiblePostPath = [cell.galleryView.collectionPosts indexPathForCell:postCell];
        
    }

    //Check if we successfuly obtained a post with a video
    if(visiblePostPath != nil){
        
        //The cell that holds the video we want, at the visible index
        PostCollectionViewCell *postCell = (PostCollectionViewCell *)[cell.galleryView.collectionPosts cellForItemAtIndexPath:visiblePostPath];
        
        //If the video current playing isn't this one, or no video has played yet
        if(![self.playingIndex isEqual:visibleIndexPath] || self.playingIndex == nil){

            [self disableVideo];
            
            self.dispatchIndex = visibleIndexPath;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //update UI in main thread.
                //Start animating the indicator
                [postCell.photoIndicatorView startAnimating];
                [UIView animateWithDuration:1.0 animations:^{
                    postCell.photoIndicatorView.alpha = 1.0f;
                }];
            });
            
            //Dispatch event to make sure the condition is true for more than .4 seconds
            double delayInSeconds = .4;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //If the video current playing isn't this one, or no video has played yet, and the index before dispatch is still the same
                if((![self.playingIndex isEqual:visibleIndexPath] || self.playingIndex == nil) && cell != nil && self.dispatchIndex == visibleIndexPath){
                    
                    [self disableVideo];
                    
                    self.playingIndex = visibleIndexPath;
                    
                    [cell.galleryView setUpPlayerWithUrl:postCell.post.video cell:postCell muted:YES buffer:YES];
                    
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

#pragma mark - Gallery Table View Cell Delegate

- (void)readMoreTapped:(FRSGallery *)gallery{
    
    [self openDetailWithGallery:gallery];
    
}

- (void)shareTapped:(FRSGallery *)gallery{
    
    NSString *string = [NSString stringWithFormat:@"%@/gallery/%@",BASE_URL, gallery.galleryID];
    NSURL *URL = [NSURL URLWithString:string];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler: ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
        if(completed){
            
            NSString *type;
            
            if(activityType == UIActivityTypePostToFacebook) type = @"Facebook";
            
            else if(activityType == UIActivityTypePostToTwitter) type = @"Twitter";
            
            else if(activityType == UIActivityTypeMail) type = @"Email";
            
            else if(activityType == UIActivityTypeCopyToPasteboard) type = @"Clipboard";
            
            else type = activityType;
            
            [Answers logShareWithMethod:type
                            contentName:@"Gallery"
                            contentType:@"gallery"
                              contentId:gallery.galleryID
                       customAttributes:@{@"location" : @"Gallery List"}];
        }
        
    }];
    
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
    
}

#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{

    if ([identifier isEqualToString:@"embedProfileHeader"]) {
        if (![self.containingViewController isKindOfClass:[ProfileViewController class]]) {
            self.tableView.tableHeaderView = nil;
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    if ([[segue identifier] isEqualToString:@"embedProfileHeader"]) {

        ProfileHeaderViewController *phvc = [segue destinationViewController];
        self.profileHeaderViewController = phvc;
        self.tableView.tableHeaderView.frame = phvc.view.bounds;
    }
}

@end
