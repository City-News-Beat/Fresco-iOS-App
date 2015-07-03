//
//  TabBarController.m
//  FrescoNews
//
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "TabBarController.h"
@import AVFoundation;
#import "SwitchingRootViewController.h"
#import "CameraViewController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "AssignmentsViewController.h"
#import "StoriesViewController.h"

@implementation TabBarController


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    UITabBarController *tabBarController = ((UITabBarController *)((SwitchingRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
    
    if ([item.title isEqualToString:@"Highlights"]) {
    
        HomeViewController *vc = (HomeViewController *) ([[tabBarController viewControllers][0] viewControllers][0]);
        
        [vc.galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
        
        [tabBarController setSelectedIndex:0];
    
    }
    else if ([item.title isEqualToString:@"Stories"]) {
        
        StoriesViewController *vc = (StoriesViewController *) ([[tabBarController viewControllers][1] viewControllers][0]);
        
        [vc.tableView setContentOffset:CGPointZero animated:YES];
        
        [tabBarController setSelectedIndex:1];
    
        
    }
    else if ([item.title isEqualToString:@"Assignments"]) {
        
//        AssignmentsViewController *vc = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
//        
//        vc.centeredUserLocation = NO;
//        
//        [vc zoomToCurrentLocation];
//        
//        [tabBarController setSelectedIndex:3];

    }
    else if ([item.title isEqualToString:@"Profile"]) {
        
        ProfileViewController *vc = (ProfileViewController *) ([[tabBarController viewControllers][4] viewControllers][0]);
        
        [vc.galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
        
        [tabBarController setSelectedIndex:4];
        
    }
    

    
    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:@"previouslySelectedTab"];
    if ([item.title isEqualToString:@"Camera"]) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusDenied) {
            [self presentCamera];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self.selectedViewController isKindOfClass:[CameraViewController class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }

    return UIInterfaceOrientationMaskPortrait;
}

- (void)presentCamera
{
    self.tabBar.hidden = YES;
    CameraViewController *vc = (CameraViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)returnToGalleryPost
{
    self.tabBar.hidden = YES;
    CameraViewController *vc = (CameraViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    [self presentViewController:vc animated:NO completion:^{
        [vc doneButtonTapped:nil];
    }];
}

@end
