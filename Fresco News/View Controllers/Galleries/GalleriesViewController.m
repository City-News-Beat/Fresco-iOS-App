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
    self.statusBarBackground.backgroundColor = [UIColor goldStatusBarColor];
    self.statusBarBackground.alpha = 0.0f;
    
    [self.view addSubview:self.statusBarBackground];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //Reset playing index for a fresh load
    self.playingIndex = nil;
    
    //Set delegate, reset in `viewWillDisappear`
    self.tableView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    //Turn off any video
    [self disableVideo];
    
    //Disable delegate, turned back on in `viewWillAppear`
    self.tableView.delegate = nil;
    
}

- (void)refresh
{
    [self.refreshControl beginRefreshing];

    if([self.parentViewController isKindOfClass:[HighlightsViewController class]]){
        
        [((HighlightsViewController *) self.parentViewController) performNecessaryFetch:YES withResponseBlock:^(BOOL success, NSError *error) {
            
            [self reloadData];
            [self.refreshControl endRefreshing];
            
        }];
        
    }
    else if([self.parentViewController isKindOfClass:[ProfileViewController class]]){
        
        [((ProfileViewController *) self.parentViewController) performNecessaryFetch:YES withResponseBlock:^(BOOL success, NSError *error) {
            [self reloadData];
            [self.refreshControl endRefreshing];
        }];
        
        [self.profileHeaderViewController updateUserInfo];
        
    }

}

- (void)reloadData{

    [self.tableView reloadData];
//    [self checkForVideo];
}

/*
** Disable any playing video
*/

- (void)disableVideo{
    
    self.playingIndex = nil;
    
    self.dispatchIndex = nil;
    
    for(GalleryTableViewCell *cell in [self.tableView visibleCells]){
        [cell.galleryView cleanUpVideoPlayer];
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

    galleryHeader.gallery = [self.galleries objectAtIndex:section];
    
    return galleryHeader;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    [self checkForVideo];

    /*
    ** Navigation Bar Conditioning
    */

//    if (self.lastContentOffset > scrollView.contentOffset.y && ( (fabs(scrollView.contentOffset.y  - self.lastContentOffset) > 200) || scrollView.contentOffset.y <=0)){
//        
//        //SHOW
//        if(self.navigationController.navigationBar.hidden == YES  && self.currentlyHidden){
//            
//            [self resetNavigationBar:YES];
//
//        }
//        
//        self.lastContentOffset = scrollView.contentOffset.y;
//        
//        
//    }
//    else if (self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 100){
//        
//        //HIDE
//        if(self.navigationController.navigationBar.hidden == NO && !self.currentlyHidden){
//            
//            self.currentlyHidden = YES;
//            
//            self.statusBarBackground.frame = [[UIApplication sharedApplication] statusBarFrame];
//            
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
//            
//            [UIView animateWithDuration:.1 animations:^{
//                self.statusBarBackground.alpha = 1.0f;
//            }];
//            
//        }
//        
//        self.lastContentOffset = scrollView.contentOffset.y;
//        
//    }
    
    
    
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
        else visiblePostPath = [cell.galleryView.collectionPosts indexPathForCell:postCell];
        
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
            
            //Dispatch event to make sure the condition is true for more than .8 seconds
            double delayInSeconds = .8;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //If the video current playing isn't this one, or no video has played yet, and the index before dispatch is still the same
                if((![self.playingIndex isEqual:visibleIndexPath] || self.playingIndex == nil) && cell != nil && self.dispatchIndex == visibleIndexPath){
                    
                    [self disableVideo];
                    
                    self.playingIndex = visibleIndexPath;
                    
                    [cell.galleryView setUpPlayerWithUrl:postCell.post.video cell:postCell];
                    
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
        if ([self.containingViewController isKindOfClass:[HighlightsViewController class]] ||
            [self.containingViewController isKindOfClass:[StoryViewController class]] ) {
            self.tableView.tableHeaderView = nil;
            [self.viewProfileHeader removeFromSuperview];
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"embedProfileHeader"]) {

            ProfileHeaderViewController *phvc = [segue destinationViewController];
            self.profileHeaderViewController = phvc;
            self.tableView.tableHeaderView.frame = phvc.view.bounds;
    }
}

@end
