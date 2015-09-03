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
@property (nonatomic, assign) BOOL initialUpdate;

@property (nonatomic, assign) BOOL disableEndlessScroll;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setFrescoNavigationBar];
    
    self.initialUpdate = NO;
    
    //Set up `handleAPIKeyAvailable` so if there's no reachability, the profile will automatically be updated when there is
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAPIKeyAvailable:) name:NOTIF_API_KEY_AVAILABLE object:nil];
    
    self.galleriesViewController.tableView.showsInfiniteScrolling = NO;

    //Endless scroll handler
    [self.galleriesViewController.tableView addInfiniteScrollingWithActionHandler:^{
        
        if(self.disableEndlessScroll){
        
            // append data to data source, insert new cells at the end of table view
            NSNumber *num = [NSNumber numberWithInteger:[[self galleries] count]];
            
            [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID offset:num shouldRefresh:NO withResponseBlock:^(id responseObject, NSError *error) {
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
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if(!self.initialUpdate || [[NSUserDefaults standardUserDefaults] boolForKey:UD_UPDATE_PROFILE]){
       
        [self populateProfile];
        
        self.initialUpdate = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UD_UPDATE_PROFILE];
    }

    if([[NSUserDefaults standardUserDefaults] boolForKey:UD_UPDATE_USER_GALLERIES]){
        
        [self performNecessaryFetch:YES withResponseBlock:nil];

        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UD_UPDATE_USER_GALLERIES];
    
    }

}

/*
** Populates view controller with galleries and the profile header
*/

- (void)populateProfile{
    
    //Load the profile header with the cached data
    if([[FRSDataManager sharedManager] isLoggedIn]){
        [self.galleriesViewController.profileHeaderViewController updateUserInfo];
    }
    
    //Load galleries only if we successfuly load them from the database
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
        
        [self performNecessaryFetch:NO withResponseBlock:nil];
    }
}


#pragma mark - NSNotificationCenter Notification handling

/*
** API Key for user is now available, run update on profile view
*/

- (void)handleAPIKeyAvailable:(NSNotification *)notification
{
    [self populateProfile];
}

#pragma mark - Data Loading

- (void)performNecessaryFetch:(BOOL)refresh withResponseBlock:(FRSRefreshResponseBlock)responseBlock{
    
    [[FRSDataManager sharedManager] getGalleriesForUser:[FRSDataManager sharedManager].currentUser.userID
                                                 offset:[NSNumber numberWithInteger:0] shouldRefresh:refresh
                                      withResponseBlock:^(id responseObject, NSError *error) {
                                          

        if(responseObject == nil || [responseObject count] == 0) {
    
            [self setUserMessage:NO];
            
            self.galleriesViewController.galleries = nil;
            
            [self.galleriesViewController.tableView reloadData];
        
        }
        else{
        
            [self setUserMessage:YES];
        
            //Check to make sure the first gallery and the response object's first gallery are different
            if([self.galleriesViewController.galleries count] == 0
               || ![((FRSGallery *)[responseObject objectAtIndex:0]).galleryID
                    isEqualToString:((FRSGallery *)[self.galleriesViewController.galleries objectAtIndex:0]).galleryID]){
            
                self.galleriesViewController.galleries = [NSMutableArray arrayWithArray:responseObject];
                [self.galleriesViewController reloadData];
        
            }
        }
                                
      if(responseBlock) responseBlock(YES, nil);
    
    }];
}

- (void)setUserMessage:(BOOL)shouldHide{
    
    if(shouldHide){
    
        self.noContentLabel.hidden = YES;
        self.noContentLabelSmall.hidden = YES;
        self.noContentImage.hidden = YES;
        
    }
    else{
    
        if(self.noContentLabel == nil && self.noContentImage == nil){
            
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:NOTHING_HERE_YET];
            NSMutableAttributedString* attrStringSmall = [[NSMutableAttributedString alloc] initWithString: OPEN_CAMERA];
            
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
            self.noContentLabel.font= [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:16.0f];
            self.noContentLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
            self.noContentLabel.alpha = .87f;
            
            self.noContentLabelSmall = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            self.noContentLabelSmall.numberOfLines = 1;
            self.noContentLabelSmall.attributedText = attrStringSmall;
            self.noContentLabelSmall.font= [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:13.0f];
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