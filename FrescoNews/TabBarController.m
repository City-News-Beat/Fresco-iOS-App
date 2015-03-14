//
//  TabBarController.m
//  FrescoNews
//
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "TabBarController.h"
#import "CameraViewController.h"

@implementation TabBarController

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Camera"]) {
        self.savedIndex = self.selectedIndex;
        CameraViewController *vc = (CameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"cameraVC"];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

@end
