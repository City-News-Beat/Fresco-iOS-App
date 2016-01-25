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
#import "AppDelegate.h"

@import FBSDKCoreKit;

#define HIDE_NUMBER @3

@interface HighlightsViewController ()

@property (nonatomic, assign) BOOL disableEndlessScroll;

@property (nonatomic, assign) BOOL initialRefresh;

@end

@implementation HighlightsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setFrescoNavigationBar];

    //Check if the app visited onboard, then go straight to updating
    
    if(((FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController).onboardVisited){
        [self initialUpdate];
    }
    
    [self initialUpdate];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) registerForPushNotifications];
    
    self.galleriesViewController.endlessScrollBlock = ^void(FRSAPISuccessBlock responseBlock){
        
        if(self.disableEndlessScroll)
            return;
    
        if([self.galleriesViewController.galleries count] == 0){
        
            responseBlock(YES, nil);
            
            return;
        
        }
        
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:[self.galleriesViewController.galleries count]];
        
        NSDictionary *params = @{@"offset" : num, @"hide" : HIDE_NUMBER, @"stories" : @"true"}; //HIDE NUMBER
        
        //Make request for more posts, append to galleries array
        [[FRSDataManager sharedManager] getGalleries:params shouldRefresh:NO withResponseBlock:^(id responseObject, NSError *error) {
            
            if (!error) {
                
                if ([responseObject count] > 0) {
                    
                    [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                    
                    [self.galleriesViewController.tableView reloadData];
                    
                    responseBlock(YES, nil);
                    
                }
                else
                    self.disableEndlessScroll = YES;
            }
            else
                responseBlock(YES, nil);
            
        }];
    };
    
    //Set up bar button items
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:HIGHLIGHTS
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email" forKey:@"fields"];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"me"
                                  parameters:parameters
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        NSDictionary *response = (NSDictionary *)result;
        
        // Handle the result
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - Data Loading

/**
 *  Performs initial update forcing refresh when app opens for the first time
 */

- (void)initialUpdate{

    [self.galleriesViewController.refreshControl beginRefreshing];
    
    [self.galleriesViewController.tableView setContentOffset:CGPointMake(0, -self.galleriesViewController.refreshControl.frame.size.height) animated:NO];
    
    [self performNecessaryFetchWithRefresh:YES withResponseBlock:^(BOOL success, NSError *error) {
        
        [self.galleriesViewController.refreshControl endRefreshing];
        [self.galleriesViewController.tableView reloadData];
        [self.galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
        
    }];
    
}

- (void)performNecessaryFetchWithRefresh:(BOOL)refresh withResponseBlock:(FRSRefreshResponseBlock)responseBlock{
    
    NSDictionary *params = @{@"offset" : @0, @"stories" : @"true", @"hide" : HIDE_NUMBER};
        
    [[FRSDataManager sharedManager] getGalleries:params shouldRefresh:refresh withResponseBlock:^(id responseObject, NSError *error){
    
        if (!error) {
            
            if ([responseObject count] > 0) {
                
                //Check to make sure the first gallery and the response object's first gallery are different
                if([self.galleriesViewController.galleries count] == 0 ||
                   ![((FRSGallery *)[responseObject objectAtIndex:0]).galleryID isEqualToString:((FRSGallery *)[self.galleriesViewController.galleries objectAtIndex:0]).galleryID] ||
                   refresh){
                    
                    self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:responseObject];
                    
                }
            }
            
            if(responseBlock) responseBlock(YES, error);

        }
        else
            if(responseBlock) responseBlock(NO, error);
        
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
