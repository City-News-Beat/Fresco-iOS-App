//
//  StoryViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryViewController.h"
#import "GalleriesViewController.h"
#import "FRSStory.h"
#import "FRSDataManager.h"
#import "UIViewController+Additions.h"

@interface StoryViewController ()
@property (weak, nonatomic) IBOutlet UIView *galleriesView;
@property (weak, nonatomic) GalleriesViewController *galleriesViewController;
@end

@implementation StoryViewController
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

}

#pragma mark - Data Loading
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"embedGalleries"]) {
        // Get reference to the destination view controller
        self.galleriesViewController = [segue destinationViewController];
        self.galleriesViewController.galleries = self.story.galleries;
        self.galleriesViewController.containingViewController = self;
    }
}
@end
