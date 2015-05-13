//
//  HomeViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "HomeViewController.h"
#import "GalleriesViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "GalleryHeader.h"
#import "GalleryTableViewCell.h"

@interface HomeViewController ()
@property (strong, nonatomic) NSArray *galleries;
@property (weak, nonatomic) IBOutlet UIView *galleriesView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *primaryAction;
@property (weak, nonatomic) GalleriesViewController *galleriesViewController;
@property (weak, nonatomic) PFUser *currentUser;
@end

@implementation HomeViewController

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
    [self setFrescoImageHeader];
    [self performNecessaryFetch:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.currentUser = [PFUser currentUser];
    
    if (self.currentUser) {
        self.primaryAction.title = @"Log Out";
    }
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getHomeDataWithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject count]) {
                self.galleries = responseObject;
                self.galleriesViewController.galleries = self.galleries;
                [self.galleriesViewController refresh];
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
    if ([[segue identifier] isEqualToString:@"embedGalleries"]) {
        // Get reference to the destination view controller
        self.galleriesViewController = [segue destinationViewController];
        self.galleriesViewController.galleries = self.galleries;
        self.galleriesViewController.containingViewController = self;
    }
}

- (IBAction)primaryAction:(id)sender {
    if (self.currentUser) {
        [PFUser logOut];
        self.primaryAction.title = @"First Run";
    } else {
        [self performSegueWithIdentifier:@"firstRunPush" sender:sender];
    }
}
@end
