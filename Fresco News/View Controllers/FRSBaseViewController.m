//
//  FRSBaseViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import "FRSNavigationController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSProfileViewController.h"
#import "FRSStoryDetailViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSCameraViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSTaxInformationViewController.h"
#import "FRSIdentityViewController.h"

@interface FRSBaseViewController ()

@property BOOL isSegueingToGallery;
@property BOOL isSegueingToStory;

@end

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

-(void)removeNavigationBarLine{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)configureBackButtonAnimated:(BOOL)animated{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    backItem.imageInsets = UIEdgeInsetsMake(2, -4.5, 0, 0);
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem animated:animated];
}

-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideTabBarAnimated:(BOOL)animated{
    if (!self.tabBarController.tabBar) return;
    
    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height;
    
    if (self.tabBarController.tabBar.frame.origin.y == yOrigin) return;
    
    self.hiddenTabBar = YES;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } completion:nil];
}

-(void)showTabBarAnimated:(BOOL)animated{
    if (!self.tabBarController.tabBar) return;
    
    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.frame.size.height;
    
    if (self.tabBarController.tabBar.frame.origin.y == yOrigin) return;
    
    self.hiddenTabBar = NO;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } completion:nil];
}

#pragma mark - Status Bar
-(void)shouldShowStatusBar:(BOOL)statusBar animated:(BOOL)animated {
    
    UIWindow *statusBarApplicationWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    
    int alpha;
    if (statusBar) {
        alpha = 1;
    } else {
        alpha = 0;
    }
    
    if (animated) {
        [UIView beginAnimations:@"fade-statusbar" context:nil];
        [UIView setAnimationDuration:0.3];
        statusBarApplicationWindow.alpha = alpha;
        [UIView commitAnimations];
    } else {
        statusBarApplicationWindow.alpha = alpha;
    }
}

#pragma mark - Deep Links

-(void)segueToPhotosOfTheDay:(NSArray *)postIDs {
    //Not part of the initial 3.0 release
}

-(void)segueToTodayInNews:(NSArray *)galleryIDs {
    
    NSMutableArray *galleryArray = [[NSMutableArray alloc] init];

    for (NSString *gallery in galleryIDs) {

        [[FRSAPIClient sharedClient] getGalleryWithUID:gallery completion:^(id responseObject, NSError *error) {
            
            if (![galleryArray containsObject:responseObject]) {
                [galleryArray addObject:(FRSGallery *)responseObject];
            }
            
            if (galleryArray.count == galleryIDs.count) {
                if (!self.isSegueingToStory) {
                    self.isSegueingToStory = YES;
                    FRSStoryDetailViewController *detailVC = [[FRSStoryDetailViewController alloc] init];
                    [detailVC configureWithGalleries:galleryArray];
                    detailVC.navigationController = self.navigationController;
                    detailVC.title = @"TODAY IN NEWS";
                    [self.navigationController pushViewController:detailVC animated:YES];
                }
            }
        }];
    }
}


-(void)segueToGallery:(NSString *)galleryID {
    
    [[FRSAPIClient sharedClient] getGalleryWithUID:galleryID completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[appDelegate managedObjectContext]];
        
        [galleryToSave configureWithDictionary:responseObject context:[appDelegate managedObjectContext]];
        
        FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:galleryToSave];
        vc.shouldHaveBackButton = YES;
        
        if (!self.isSegueingToGallery) {
            self.isSegueingToGallery = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        [self hideTabBarAnimated:YES];
    }];
}

-(void)segueToStory:(NSString *)storyID {
    
    [[FRSAPIClient sharedClient] getStoryWithUID:storyID completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:[appDelegate managedObjectContext]];
        
        [story configureWithDictionary:responseObject];
        
        FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:story];
        detailView.navigationController = self.navigationController;
        
        if (!self.isSegueingToStory) {
            self.isSegueingToStory = YES;
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }];
}

-(FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

-(void)segueToUser:(NSString *)userID {
    
    FRSProfileViewController *profileVC = [[FRSProfileViewController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(void)segueToPost:(NSString *)postID {
    [[FRSAPIClient sharedClient] getPostWithID:postID completion:^(id responseObject, NSError *error) {
        
        [self segueToGallery:[[responseObject objectForKey:@"parent"] objectForKey:@"id"]];
        
    }];
}

-(void)segueToAssignmentWithID:(NSString *)assignmentID {
    
    FRSNavigationController *navCont = (FRSNavigationController *)[self.tabBarController.viewControllers objectAtIndex:3];
    FRSAssignmentsViewController *assignmentsVC = (FRSAssignmentsViewController *)[navCont.viewControllers objectAtIndex:0];
    
    assignmentsVC.hasDefault = YES;
    assignmentsVC.defaultID = assignmentID;
    self.tabBarController.selectedIndex = 3;
    
    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
        
        [assignmentsVC focusOnAssignment:(FRSAssignment *)responseObject];
        [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.3];
    }];
}

-(void)segueToCameraWithAssignmentID:(NSString *)assignmentID {
    
    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
        
        NSDictionary *assDict = [[NSDictionary alloc] init];
        assDict = responseObject; //lol
        
        FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo selectedAssignment:assDict selectedGlobalAssignment:nil];
        UINavigationController *navControl = [[UINavigationController alloc] init];
        navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
        [navControl pushViewController:cam animated:NO];
        [navControl setNavigationBarHidden:YES];
        
        [self presentViewController:navControl animated:YES completion:nil];
    }];
}

-(void)segueHome {
    self.tabBarController.selectedIndex = 0;
    [self popViewController];
}

-(void)segueToDebitCard {
    FRSDebitCardViewController *debitCardVC = [[FRSDebitCardViewController alloc] init];
    [self.navigationController pushViewController:debitCardVC animated:YES];
}

-(void)segueToTaxInfo {
    FRSTaxInformationViewController *taxVC = [[FRSTaxInformationViewController alloc] init];
    [self.navigationController pushViewController:taxVC animated:YES];
}

-(void)segueToIDInfo {
    FRSIdentityViewController *identityVC = [[FRSIdentityViewController alloc] init];
    [self.navigationController pushViewController:identityVC animated:YES];

}




@end
