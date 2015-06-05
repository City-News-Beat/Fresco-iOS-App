//
//  ProfileViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ProfileViewController.h"
#import "GalleriesViewController.h"
#import "FRSDataManager.h"
#import "UIViewController+Additions.h"
#import "ProfileHeaderViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *galleriesView;
@property (weak, nonatomic) GalleriesViewController *galleriesViewController;
@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFrescoNavigationBar];
    [self performNecessaryFetch:nil];
    
    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        // append data to data source, insert new cells at the end of table view
        NSNumber *num = [NSNumber numberWithInteger:[[self galleries] count]];
        
        [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:num WithResponseBlock:^(id responseObject, NSError *error) {
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

- (void)viewWillAppear:(BOOL)animated
{
    if (![FRSDataManager sharedManager].currentUser) {
        [self navigateToFirstRun];
    }
    else {
        [super viewWillAppear:animated];
        [self performNecessaryFetch:nil];
    }
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:0 WithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject count]) {
                self.galleries = responseObject;
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:self.galleries];
                [self.galleriesViewController.tableView reloadData];
            }
        }
        [self reloadData];
    }];
}

- (void)reloadData
{
    
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
