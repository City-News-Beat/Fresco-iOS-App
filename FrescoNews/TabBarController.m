//
//  TabBarController.m
//  FrescoNews
//
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "TabBarController.h"
#import "CameraViewController.h"
#import "FRSUser.h"

@implementation TabBarController

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Camera"]) {
        if ([FRSUser loggedInUserId]) {
            self.savedIndex = self.selectedIndex;
            self.tabBar.hidden = YES;
            CameraViewController *vc = (CameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"cameraVC"];
            [self presentViewController:vc animated:NO completion:nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Required"
                                                            message:@"Please login to access the camera and post to Fresco"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
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

@end
