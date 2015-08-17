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
    
    [super viewDidLoad];
    
    self.title = @"Story";
    
    [self performNecessaryFetch:nil];
    
    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        if([self.offset integerValue] != 0){
            
            NSArray *galleryIds;
            
            //Load by intervals of 10
            if(self.story.galleryIds.count > ([self.offset integerValue] + 10)){
                
                // append data to data source, insert new cells at the end of table view
                galleryIds = [self.story.galleryIds subarrayWithRange:NSMakeRange([self.offset integerValue],10)];
                
                self.offset = [NSNumber numberWithInteger:([self.offset integerValue] + 10)];
                
            }
            else{
                
                galleryIds = [self.story.galleryIds subarrayWithRange:NSMakeRange([self.offset integerValue], (self.story.galleryIds.count - [self.offset integerValue]))];
                
                self.offset = 0;
                
            }
            
            //Make request for more posts, append to galleries array
            [[FRSDataManager sharedManager] getGalleriesFromIds:galleryIds responseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    if ([responseObject count]) {
                        
                        [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                        
                        [self.galleriesViewController.tableView reloadData];
                        
                    }
                }
            }];
        
        }

        
        [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];
        
    }];

}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    
    NSArray *galleryIds;
    
    if(self.story.galleryIds.count > 10){
        
        galleryIds = [self.story.galleryIds subarrayWithRange:NSMakeRange(0, 10)];
        
        self.offset = [NSNumber numberWithInt:10];
    }
    else{
    
        galleryIds = self.story.galleryIds;
        
        self.offset = nil;
    }

    
    [[FRSDataManager sharedManager] getGalleriesFromIds:galleryIds responseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            
            if ([responseObject count]) {
                
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:responseObject];
                [self.galleriesViewController.tableView reloadData];
                
                if(self.selectedThumbnail){
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:self.selectedThumbnail];
                    
                    if(self.selectedThumbnail  < [responseObject count]){
                        
                        [self.galleriesViewController.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        
                        self.galleriesViewController.currentlyHidden = NO;
                        
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
        self.galleriesViewController.currentlyHidden = YES;
        self.galleriesViewController.containingViewController = self;
        
    }
    
}

@end
