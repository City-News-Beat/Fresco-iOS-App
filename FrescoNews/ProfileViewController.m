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
#import "FirstRunViewController.h"
#import "FRSDataManager.h"
#import "UIViewController+Additions.h"

@interface ProfileViewController ()
//@property (weak, nonatomic) IBOutlet UIView *profileView;
//@property (weak, nonatomic) IBOutlet UIView *profileWrapperView;
//@property (strong, nonatomic) NSArray *galleries;
@property (weak, nonatomic) IBOutlet UIView *galleriesView;
@property (weak, nonatomic) GalleriesViewController *galleriesViewController;
@property (weak, nonatomic) FirstRunViewController *firstRunViewController;
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
    [self setFrescoImageHeader];
    [self performNecessaryFetch:nil];
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
    [[FRSDataManager sharedManager] getGalleriesWithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject count]) {
                self.galleries = responseObject;
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:self.galleries];
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
    if ([[segue identifier] isEqualToString:@"embedGalleries"])
    {
        // Get reference to the destination view controller
        self.galleriesViewController = [segue destinationViewController];
        self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:self.galleries];
        self.galleriesViewController.containingViewController = self;
    }

}
@end
