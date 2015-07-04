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

@implementation TabBarController

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
