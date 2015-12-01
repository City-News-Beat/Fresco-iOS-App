//
//  TabBarController.m
//  FrescoNews
//
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;
@import FBSDKShareKit;


#import "FRSTabBarController.h"
#import "UIViewController+Additions.h"
#import "FRSCamViewController.h"
#import "HighlightsViewController.h"
#import "AssignmentsViewController.h"
#import "ProfileViewController.h"
#import "StoriesViewController.h"
#import "NotificationsViewController.h"
#import "FRSFirstRunWrapperViewController.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "UIViewController+Additions.h"
#import "FRSLocationManager.h"
#import "FRSAlertViewManager.h"



@implementation FRSTabBarController

#pragma mark - Initialization

-(id)initWithCoder:(NSCoder *)aDecoder{

    if(self = [super initWithCoder:aDecoder]){

        [self setupTabBarAppearances];
        
        self.delegate = self;
        

    }
    
    return self;
}

- (void)viewDidLoad{

    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(galleryUploadComplete:) name:@"Gallery Upload Done" object:nil];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}

-(void)galleryUploadComplete:(NSNotification *)sender{
    NSDictionary *info = sender.userInfo;
    NSString *url = info[@"url"];
    NSString *title = info[@"title"];
    if (!url || !title) return;
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    content.contentTitle = title;
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self;
    dialog.shareContent = content;
    dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
    if (![dialog canShow]) {
        // fallback presentation when there is no FB app
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
    }
    [dialog show];

//    [FBSDKShareDialog showFromViewController:self
//                                 withContent:content
//                                    delegate:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    //Camera
    if ([item.title isEqualToString:@"Camera"]) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            [self presentCamera];
        }
    }
}

- (void)presentCamera
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:UD_PREVIOUSLY_SELECTED_TAB];
    
    FRSCamViewController *vc = (FRSCamViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    
    [self presentViewController:vc animated:YES completion:nil];

}

- (void)returnToGalleryPost
{
    FRSCamViewController *vc = (FRSCamViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    
    [self presentViewController:vc animated:NO completion:^{
        [vc doneButtonTapped:nil];
    }];
}

#pragma mark - TabBarController Appearence

- (void)setupTabBarAppearances
{
    if(IS_IPHONE_4S){
        
        NSMutableArray *tabbarViewControllers = [NSMutableArray arrayWithArray: [self viewControllers]];
        
        [tabbarViewControllers removeObjectAtIndex:4];
        
        [tabbarViewControllers removeObjectAtIndex:3];
        
        [tabbarViewControllers removeObjectAtIndex:2];
        
        [self setViewControllers: tabbarViewControllers];
        
    }

    NSArray *highlightedTabNames = @[@"tab-home-highlighted",
                                     @"tab-stories-highlighted",
                                     @"tab-camera-highlighted",
                                     @"tab-assignments-highlighted",
                                     @"tab-profile-highlighted"];
    
    UITabBar *tabBar = self.tabBar;
    
    int i = 0;
    
    for (UITabBarItem *item in tabBar.items) {
        if (i == 2) {
            item.image = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.selectedImage = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0);
        }
        else {
            item.selectedImage = [UIImage imageNamed:highlightedTabNames[i]];
        }
        ++i;
    }
    
}

#pragma mark - TabBarController Delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_VIEW_DISMISS object:nil];

    UIViewController *vc = [viewController.childViewControllers firstObject];
    
    if ([vc isMemberOfClass:[HighlightsViewController class]] && tabBarController.selectedIndex == 0) {
        
        if([[vc.navigationController visibleViewController] isKindOfClass:[HighlightsViewController class]]){
            
            NSIndexPath *top = [NSIndexPath indexPathForItem:NSNotFound inSection:0];
            
            [((HighlightsViewController *)vc).galleriesViewController.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
        else{
            [vc.navigationController popViewControllerAnimated:YES];
        }

        return NO;
    }
    else if ([vc isMemberOfClass:[StoriesViewController class]] && tabBarController.selectedIndex == 1) {
        
        if([[vc.navigationController visibleViewController] isKindOfClass:[StoriesViewController class]]){
            
            NSIndexPath *top = [NSIndexPath indexPathForItem:NSNotFound inSection:0];
            
            if (((StoriesViewController *)vc).tableView.numberOfSections > 0)
                [((StoriesViewController *)vc).tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
        else{
            [vc.navigationController popViewControllerAnimated:YES];
        }
        
        return NO;
    }
    else if ([vc isMemberOfClass:[AssignmentsViewController class]] && tabBarController.selectedIndex == 3) {
        //Zoom to location
        ((AssignmentsViewController *)vc).centeredUserLocation = NO;
        [((AssignmentsViewController *)vc) zoomToCurrentLocation];
        return NO;
    }
    else if ([vc isMemberOfClass:[ProfileViewController class]]) {
    
        //Check if we are already at this tab
        if(tabBarController.selectedIndex == 4){
        
            if([[vc.navigationController visibleViewController] isKindOfClass:[ProfileViewController class]]){
                
                NSIndexPath *top = [NSIndexPath indexPathForItem:NSNotFound inSection:0];
                
                if (((ProfileViewController *)vc).galleriesViewController.galleries){
                    
                    [((ProfileViewController *)vc).galleriesViewController.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                
            }
            else{
                
                
                [vc.navigationController popViewControllerAnimated:YES];
            }
            
            return NO;
            
        }
        //Otherwise check for log in, and present the login screen otherwise
        else{
        
            if(![[FRSDataManager sharedManager] isLoggedIn]){
                
                FRSFirstRunWrapperViewController *vc = [[FRSFirstRunWrapperViewController alloc] init];
                
                [self presentViewController:vc animated:YES completion:nil];
                
                return NO;
            }
        }
    }
    else if(vc == nil){
        
        //Check for permissions
        
        
        BOOL cameraDisabled = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied;
        BOOL locationDisabled = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
        
        if (cameraDisabled || locationDisabled){
            
            NSString *title;
            NSString *message;
            
            if (cameraDisabled && locationDisabled){
                title = ENABLE_CAMERA_LOCATION_TITLE;
                message = ENABLE_CAMERA_LOCATION_SETTINGS;
            }
            else if (cameraDisabled && !locationDisabled){
                title = ENABLE_CAMERA_TITLE;
                message = ENABLE_CAMERA_SETTINGS;
            }
            else {
                title = ENABLE_LOCATION_TITLE;
                message = ENABLE_LOCATION_SETTINGS;
            }
            
            UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Close"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               
                                           }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"Enable"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                       }];
            
            [alertCon addAction:cancelAction];
            [alertCon addAction:okAction];
            
            [self presentViewController:alertCon animated:YES completion:nil];
            
            return NO;
            
        }
    }
    
    return YES;
    
}

@end
