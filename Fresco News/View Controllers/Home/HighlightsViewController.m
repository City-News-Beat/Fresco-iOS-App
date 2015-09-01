//
//  HomeViewController.m
//  FrescoNews
//
//  Created by Fresco News on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "HighlightsViewController.h"
#import "FRSRootViewController.h"
#import "GalleriesViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "GalleryHeader.h"
#import "GalleryTableViewCell.h"
#import "AssignmentsViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface HighlightsViewController ()

@property (nonatomic, assign) BOOL disableEndlessScroll;

@property (nonatomic, assign) BOOL initialRefresh;

@end

@implementation HighlightsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Check if the app visited onbard, then go straight to updating
    if(((FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController).onboardVisited){
    
        [self updateHighlights:nil];
    
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHighlights:) name:NOTIF_REACHABILITY_MONITORING object:nil];
    
    [self setFrescoNavigationBar];
    
    self.galleriesViewController.tableView.showsInfiniteScrolling = NO;

    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:[self.galleriesViewController.galleries count]];
        
        NSDictionary *params = @{@"offset" : num, @"hide" : @"1", @"stories" : @"true"};
        
        //Make request for more posts, append to galleries array
        [[FRSDataManager sharedManager] getGalleries:params shouldRefresh:NO withResponseBlock:^(id responseObject, NSError *error) {
            
            if (!error) {
                if ([responseObject count] > 0) {
                    
                    [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                    
                    [self.galleriesViewController.tableView reloadData];

                }
                
                [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];
                
            }
            
        }];
    }];
    
    //Set up bar button items
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:HIGHLIGHTS
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
}

#pragma mark - Data Loading

/*
** Notification listener telling us the reachability manager is ready
*/

- (void)updateHighlights:(NSNotification *)notification {

    //Check for initial refresh,
    if(!self.initialRefresh){
        
        [self.galleriesViewController.refreshControl beginRefreshing];
        
        [self.galleriesViewController.tableView setContentOffset:CGPointMake(0, -self.galleriesViewController.refreshControl.frame.size.height) animated:NO];
        
        [self performNecessaryFetch:YES withResponseBlock:^(BOOL success, NSError *error) {
            
            if(success){
                
                //Wait one second so the animation doesn't jitter
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    
                    [self.galleriesViewController.refreshControl endRefreshing];
                    
                    [self.galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
                    
                });
            }
            
        }];
        
    }
    //Perform update without refresh
    else{
        [self performNecessaryFetch:NO withResponseBlock:nil];
    }

}

/*
** General data command for fetching initial highlights (galleries)
*/

- (void)performNecessaryFetch:(BOOL)refresh withResponseBlock:(FRSRefreshResponseBlock)responseBlock{
    
    NSDictionary *params = @{@"offset" : @0, @"stories" : @"true", @"hide" : @"1"};
        
    [[FRSDataManager sharedManager] getGalleries:params shouldRefresh:refresh withResponseBlock:^(id responseObject, NSError *error){
    
        if (!error) {
            
            if ([responseObject count]) {
                
                //Check to make sure the first gallery and the response object's first gallery are different
                if([self.galleriesViewController.galleries count] == 0
                   || ![((FRSGallery *)[responseObject objectAtIndex:0]).galleryID
                        isEqualToString:((FRSGallery *)[self.galleriesViewController.galleries objectAtIndex:0]).galleryID]
                   || refresh){
                
                    self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:responseObject];
                    
                    [self.galleriesViewController reloadData];
                    
                    if(responseBlock) responseBlock(YES, nil);

                }
            }
        }
        else {
         
            if(responseBlock) responseBlock(NO, nil);
            
        }
    
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"embedGalleries"]) {
        // Get reference to the destination view controller
        self.galleriesViewController = [segue destinationViewController];
        self.galleriesViewController.containingViewController = self;
    }
}

@end
