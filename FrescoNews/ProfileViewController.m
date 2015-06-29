//
//  ProfileViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import FBSDKCoreKit;
@import FBSDKLoginKit;
#import "ProfileViewController.h"
#import "GalleriesViewController.h"
#import "FRSDataManager.h"
#import "UIViewController+Additions.h"
#import "ProfileHeaderViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIView *galleriesView;
@property (weak, nonatomic) GalleriesViewController *galleriesViewController;
@property (strong, nonatomic) UILabel *noContentLabel;
@property (nonatomic, assign) BOOL loginChecked;

@property (nonatomic, assign) BOOL disableEndlessScroll;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFrescoNavigationBar];
    

    if ([FRSDataManager sharedManager].currentUser == nil) {
        [self navigateToFirstRun];
    }
    else {
        [self performNecessaryFetch:nil];
        [super viewDidLoad];
    }

 
    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        if(self.disableEndlessScroll){
        
            // append data to data source, insert new cells at the end of table view
            NSNumber *num = [NSNumber numberWithInteger:[[self galleries] count]];
            
            [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:num WithResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    if ([responseObject count]) {
                        
                        [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                        
                        [self.galleriesViewController.tableView reloadData];
                        
                        self.noContentLabel.hidden = YES;

                    }
                    else self.disableEndlessScroll = YES;
                }

            }];
            
        }
        
        [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];


    }];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Profile"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([FRSDataManager sharedManager].currentUser == nil) {
        [self navigateToFirstRun];
    }
    else {
        [super viewWillAppear:animated];
    }
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:0 WithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            
            if(responseObject == nil || [responseObject count] == 0){
    
                self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 150, 100)];
                
                self.noContentLabel.text = @"Upload content to see it appear here";
                
                self.noContentLabel.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                
                [self.noContentLabel sizeToFit];
                
                self.noContentLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
                
                [self.view addSubview:self.noContentLabel];
            
            }
            else{
            
                self.galleries = responseObject;
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:self.galleries];
                [self.galleriesViewController.tableView reloadData];
            
            
            }
            
        }
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"embedGalleries"])
    {
        // Get reference to the destination view controller
        self.galleriesViewController = [segue destinationViewController];
        self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:self.galleries];
        self.galleriesViewController.containingViewController = self;
        self.galleriesViewController.frsUser = [FRSDataManager sharedManager].currentUser;
    }
}
@end
