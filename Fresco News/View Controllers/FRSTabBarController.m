//
//  TabBarController.m
//  FrescoNews
//
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;

#import "FRSTabBarController.h"
#import "UIViewController+Additions.h"
#import "CameraViewController.h"
#import "HighlightsViewController.h"
#import "AssignmentsViewController.h"
#import "ProfileViewController.h"
#import "StoriesViewController.h"
#import "NotificationsViewController.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "UIViewController+Additions.h"

@implementation FRSTabBarController

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(id)initWithCoder:(NSCoder *)aDecoder{

    if(self = [super initWithCoder:aDecoder]){

        [self setupTabBarAppearances];
        
        self.delegate = self;
    
    }
    
    return self;

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    //Camera
    if ([item.title isEqualToString:@"Camera"]) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusDenied) {
            [self presentCamera];
        }
    }
}

- (void)presentCamera
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:UD_PREVIOUSLY_SELECTED_TAB];
    
    CameraViewController *vc = (CameraViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    
    //Custom addition
    [self presentViewController:vc withScale:YES];

}

- (void)returnToGalleryPost
{
    CameraViewController *vc = (CameraViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    
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
    
    //Check if the user is not logged in (we check PFUser here, instead of the datamanger, because the user is loaded asynchrously, and we might have the user on disk before we have the DB user)
    
    if ([viewController isMemberOfClass:[TemplateCameraViewController class]]) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied) {
            
            UIAlertController *alertCon = [[FRSAlertViewManager sharedManager]
                                           alertControllerWithTitle:ENABLE_CAMERA_TITLE
                                           message:GO_TO_SETTINGS
                                           action:DISMISS handler:nil];
            
            [alertCon addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
            }]];
            
            [self presentViewController:alertCon animated:YES completion:nil];
            
        }
        return NO;
    }
    else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_VIEW_DISMISS object:nil];

        UIViewController *vc = [viewController.childViewControllers firstObject];
        
        if ([vc isMemberOfClass:[HighlightsViewController class]] && tabBarController.selectedIndex == 0) {
            
            if([[vc.navigationController visibleViewController] isKindOfClass:[HighlightsViewController class]]){
                
                [((HighlightsViewController *)vc).galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
                
            }
            else{
                [vc.navigationController popViewControllerAnimated:YES];
            }

            return NO;
        }
        else if ([vc isMemberOfClass:[StoriesViewController class]] && tabBarController.selectedIndex == 1) {
            
            if([[vc.navigationController visibleViewController] isKindOfClass:[StoriesViewController class]]){
                [((StoriesViewController *)vc).tableView setContentOffset:CGPointZero animated:YES];
            }
            else{
                [vc.navigationController popViewControllerAnimated:YES];
            }
            
            return NO;
        }
        else if ([vc isMemberOfClass:[AssignmentsViewController class]] && tabBarController.selectedIndex == 3) {
            //Zoom to location
            [((AssignmentsViewController *)vc) setCenteredUserLocation:NO];
            [((AssignmentsViewController *)vc) zoomToCurrentLocation];
            return NO;
        }
        else if ([vc isMemberOfClass:[ProfileViewController class]]) {
        
            if(tabBarController.selectedIndex == 4){
            
                if([[vc.navigationController visibleViewController] isKindOfClass:[ProfileViewController class]]){
                    
                    [((ProfileViewController *)vc).galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
                    
                }
                else{
                    [vc.navigationController popViewControllerAnimated:YES];
                }
                
                return NO;
                
            }
            else{
            
                if(![[FRSDataManager sharedManager] isLoggedIn]){
                    
                    FRSRootViewController *rvc = (FRSRootViewController *)self.parentViewController;
                    
                    [rvc presentFirstRunViewController:self];
                    
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        //reset clicked
    }
}

@end
