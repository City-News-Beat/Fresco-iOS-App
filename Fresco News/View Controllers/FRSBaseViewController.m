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
    
    //    [self configureNavigationBar];
    // Do any additional setup after loading the view.
}

//-(void)configureNavigationBar{
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
//    self.navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
//
//
//
////    [self configureBackButton];
//}

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
        
        NSLog(@"GALLERY OBJECT: %@", galleryToSave);
    }];
}


-(void)segueToStory:(NSString *)storyID {
    
    [[FRSAPIClient sharedClient] getStoryWithUID:storyID completion:^(id responseObject, NSError *error) {
        
        NSLog(@"STORY ID: %@", storyID);
        NSLog(@"RESPONSE OBJ: %@", responseObject);
        
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




@end
