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
    
    [self performNecessaryFetch:NO withResponseBlock:nil];
    
    [self setFrescoNavigationBar];
    
    self.galleriesViewController.tableView.showsInfiniteScrolling = NO;

    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:[self.galleriesViewController.galleries count]];
        
        NSDictionary *params = @{@"offset" : num};
        
        //Make request for more posts, append to galleries array
        [[FRSDataManager sharedManager] getGalleries:params shouldRefresh:NO withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                if ([responseObject count]) {
                    
                    [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                    
                    [self.galleriesViewController.tableView reloadData];
                    
                    [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];
                    
                }
            }
        }];
        
        
    }];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:HIGHLIGHTS
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(BOOL)refresh withResponseBlock:(FRSRefreshResponseBlock)responseBlock{
    
    NSDictionary *params = @{@"offset" : @0, @"stories" : @"true"};
        
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

                }
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
