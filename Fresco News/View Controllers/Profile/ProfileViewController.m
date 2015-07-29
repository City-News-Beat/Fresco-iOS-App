//
//  ProfileViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/9/15.
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
@property (strong, nonatomic) UILabel *noContentLabel;
@property (strong, nonatomic) UILabel *noContentLabelSmall;
@property (strong, nonatomic) UIImageView *noContentImage;
@property (nonatomic, assign) BOOL loginChecked;

@property (nonatomic, assign) BOOL disableEndlessScroll;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setFrescoNavigationBar];
    
    //Set up `handleAPIKeyAvailable` so if there's no reachability, the profile will automatically be updated when there is
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAPIKeyAvailable:) name:kNotificationAPIKeyAvailable object:nil];
    
    self.galleriesViewController.tableView.showsInfiniteScrolling = NO;

    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        if(self.disableEndlessScroll){
        
            // append data to data source, insert new cells at the end of table view
            NSNumber *num = [NSNumber numberWithInteger:[[self galleries] count]];
            
            [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:num WithResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    if ([responseObject count] > 0) {
                        
                        [self.galleriesViewController.galleries addObjectsFromArray:responseObject];
                        
                        [self.galleriesViewController.tableView reloadData];
                        
                        self.noContentLabel.hidden = YES;
                        self.noContentLabelSmall.hidden = YES;

                    }
                    else self.disableEndlessScroll = YES;
                }

            }];
            
        }
        
        [self.galleriesViewController.tableView.infiniteScrollingView stopAnimating];


    }];
    
    //Set up bar button item to show contextual "Me"
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Me"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:[self navigationController]
                                                                     action:@selector(popViewControllerAnimated:)];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
    //Run populate on header and galleries
    [self populateProfile];
    
}

- (void)viewDidAppear:(BOOL)animated{

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"runUpdateOnProfile"]){
        
        [self performNecessaryFetch:nil];
    
        //Ensures that update is ran on profile view controller
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"runUpdateOnProfile"];
    
    }

}


#pragma mark - NSNotificationCenter Notification handling

- (void)handleAPIKeyAvailable:(NSNotification *)notification
{
    [self populateProfile];
}

- (void)populateProfile{

    [self performNecessaryFetch:nil];
    
    [self.galleriesViewController.profileHeaderViewController updateUserInfo];

}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
    [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:0 WithResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            
            if(responseObject == nil || [responseObject count] == 0){
            
                if(self.noContentLabel == nil && self.noContentImage == nil){
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: @"Nothing here yet!"];
                    NSMutableAttributedString* attrStringSmall = [[NSMutableAttributedString alloc] initWithString: @"Open your camera to get started"];
                    
                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                    
                    [style setLineSpacing:18];
                    [style setAlignment:NSTextAlignmentCenter];
                    [attrString addAttribute:NSParagraphStyleAttributeName
                                       value:style
                                       range:NSMakeRange(0, attrString.length)];
                    
                    [attrStringSmall addAttribute:NSParagraphStyleAttributeName
                                       value:style
                                       range:NSMakeRange(0, attrString.length)];
        
                    self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
                    self.noContentLabel.numberOfLines = 1;
                    self.noContentLabel.attributedText = attrString;
                    self.noContentLabel.font= [UIFont fontWithName:@"HelveticaNeue-Regular" size:16.0f];
                    self.noContentLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
                    self.noContentLabel.alpha = .87f;
                    
                    self.noContentLabelSmall = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
                    self.noContentLabelSmall.numberOfLines = 1;
                    self.noContentLabelSmall.attributedText = attrStringSmall;
                    self.noContentLabelSmall.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                    self.noContentLabelSmall.center = CGPointMake(self.view.center.x, self.view.center.y + 30);
                    self.noContentLabelSmall.alpha = .54f;
                    
                    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
                    tapGestureRecognizer.numberOfTapsRequired = 1;
                    [self.noContentLabelSmall addGestureRecognizer:tapGestureRecognizer];
                    self.noContentLabelSmall.userInteractionEnabled = YES;
                    
                    self.noContentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noPhoto"]];
                    self.noContentImage.frame = CGRectMake(0, 0, 100, 100);
                    self.noContentImage.contentMode = UIViewContentModeScaleAspectFit;
                    self.noContentImage.center = CGPointMake(self.view.center.x, self.view.center.y - 70);
                    self.noContentImage.alpha = .54f;
                    
                    [self.view addSubview:self.noContentImage];
                    [self.view addSubview:self.noContentLabel];
                    [self.view addSubview:self.noContentLabelSmall];
                    
                }
            
            }
            else{
            
                self.galleries = responseObject;
                self.noContentLabel.hidden = YES;
                self.noContentLabelSmall.hidden = YES;
                self.noContentImage.hidden = YES;
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:self.galleries];
                [self.galleriesViewController.tableView reloadData];
            
            }
        
        }
    }];
}

#pragma mark - UITapGestureRecognizer

- (void)labelTapped:(UITapGestureRecognizer *)sender {

    [self navigateToCamera];

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
