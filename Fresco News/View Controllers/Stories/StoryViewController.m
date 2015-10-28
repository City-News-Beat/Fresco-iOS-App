//
//  StoryViewController.m
//  FrescoNews
//
//  Created by Fresco News on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIScrollView+SVInfiniteScrolling.h>
#import "StoryViewController.h"
#import "GalleriesViewController.h"
#import "FRSStory.h"
#import "FRSDataManager.h"
#import "UIViewController+Additions.h"
#import "StoriesViewController.h"

@interface StoryViewController ()

@property (strong, nonatomic) NSNumber *offset;

@end

@implementation StoryViewController

- (void)viewDidLoad
{
    
    #warning Don't let this page refresh
    [super viewDidLoad];
    
    self.title = self.story.title;
    
    [self performNecessaryFetch:nil];
    
    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *offset = [NSNumber numberWithInteger:[self.galleriesViewController.galleries count]];
        
        [[FRSDataManager sharedManager] getGalleriesFromStory:self.story.storyID withOffset:offset responseBlock:^(id responseObject, NSError *error){
            
            if (!error) {
                
                if ([responseObject count]) {
                    
                    [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                    
                    [self.galleriesViewController.tableView reloadData];
    
                }
            }
            
            [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    
    if(self.galleries != nil){
    
        self.galleriesViewController.galleries = self.galleries;
        [self.galleriesViewController.tableView reloadData];
        
        return;
        
    }
    
    [[FRSDataManager sharedManager] getGalleriesFromStory:self.story.storyID withOffset:[NSNumber numberWithInteger:0] responseBlock:^(id responseObject, NSError *error){
        
        if (!error) {
            
            if ([responseObject count]) {
                    
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:responseObject];
                
                [self.galleriesViewController.tableView reloadData];
                
                //Check if there is a gallery selected from the thumbnail
                if(self.selectedGallery){

                    NSUInteger galleryIndex = 0;

                    BOOL galleryFound = NO;

                    //Loop through the galleries and find the corresponding cell
                    for (FRSGallery *gallery in self.galleriesViewController.galleries) {
                        galleryIndex ++;
                        if([gallery.galleryID isEqualToString:self.selectedGallery]){
                            galleryFound = YES;
                            break;
                        }
                    }

                    //If the index matches
                    if(galleryIndex > 0 && galleryFound){

                        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:galleryIndex -1];

                        [self.galleriesViewController.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        
                    }
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
