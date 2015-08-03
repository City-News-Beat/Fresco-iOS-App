//
//  HomeViewController.m
//  FrescoNews
//
//  Created by Fresco News on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "HighlightsViewController.h"
#import "GalleriesViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "GalleryHeader.h"
#import "GalleryTableViewCell.h"
#import "AssignmentsViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface HighlightsViewController ()

@property (nonatomic, assign) BOOL disableEndlessScroll;

@end

@implementation HighlightsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFrescoNavigationBar];
    [self performNecessaryFetch:nil withRefresh:NO];
    
    self.galleriesViewController.tableView.showsInfiniteScrolling = NO;

    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:[self.galleriesViewController.galleries count]];
        
        NSDictionary *params = @{@"offset" : num, @"invalidate" : @"false"};
        
        //Make request for more posts, append to galleries array
        [[FRSDataManager sharedManager] getGalleries:params withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                if ([responseObject count]) {
                    
                    [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                    
                    [self.galleriesViewController.tableView reloadData];
                    
                    [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];
                    
                }
            }
        }];
        
        
    }];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Highlights"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock withRefresh:(BOOL)refresh
{
    NSDictionary *params;
    
    if(refresh)
        params = @{@"offset" : @0, @"invalidate" : @"1"};
    else
        params = @{@"offset" : @0, @"invalidate" : @"0"};
        
    [[FRSDataManager sharedManager] getGalleries:params withResponseBlock:^(id responseObject, NSError *error){
    
        if (!error) {
            if ([responseObject count]) {
                
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:responseObject];
                [self.galleriesViewController.tableView reloadData];
                //                self.galleriesViewController.galleries = self.galleries;
                //                ((FRSPost *)((FRSGallery *)self.galleries[0]).posts[0]).mediaURLString = @"http://newsbreaks.fresconews.com/uploads/14/f6af6fa4b1c226894cf66140d256bf65f76418e8.mp4";
                //                ((FRSPost *)((FRSGallery *)self.galleries[0]).posts[0]).type = @"video";
            }
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
