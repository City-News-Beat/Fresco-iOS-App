//
//  TabBarController.m
//  FrescoNews
//
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;

#import "FRSTabBarController.h"
#import "FRSRootViewController.h"
#import "CameraViewController.h"
#import "HomeViewController.h"
#import "AssignmentsViewController.h"
#import "ProfileViewController.h"
#import "StoriesViewController.h"

@implementation FRSTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder{

    if(self = [super initWithCoder:aDecoder]){

        [self setupTabBarAppearances];
        
        self.delegate = self;
    
    }
    
    return self;

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
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
    
    [self presentViewController:vc animated:YES completion:^{
       
    }];
}

- (void)returnToGalleryPost
{
    self.tabBar.hidden = YES;
    CameraViewController *vc = (CameraViewController *)[[UIStoryboard storyboardWithName:@"Camera" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"cameraVC"];
    [self presentViewController:vc animated:NO completion:^{
        [vc doneButtonTapped:nil];
    }];
}

#pragma mark - TabBarController Appearence

- (void)setupTabBarAppearances
{
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
    if ([viewController isMemberOfClass:[TemplateCameraViewController class]]) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Camera"
                                                            message:@"Fresco needs permission to access the camera to continue."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Go to Settings", nil];
            [alert show];
        }
        
        return NO;
    }
    else {
        UIViewController *vc = [viewController.childViewControllers firstObject];
        if ([vc isMemberOfClass:[HomeViewController class]] && tabBarController.selectedIndex == 0) {
            [((HomeViewController *)vc).galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
            return NO;
        }
        else if ([vc isMemberOfClass:[StoriesViewController class]] && tabBarController.selectedIndex == 1) {
            [((StoriesViewController *)vc).tableView setContentOffset:CGPointZero animated:YES];
            return NO;
        }
        else if ([vc isMemberOfClass:[ProfileViewController class]] && tabBarController.selectedIndex == 4) {
            [((ProfileViewController *)vc).galleriesViewController.tableView setContentOffset:CGPointZero animated:YES];
            return NO;
        }
    }
    
    return YES;
}

@end
