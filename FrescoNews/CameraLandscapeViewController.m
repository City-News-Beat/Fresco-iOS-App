//
//  CameraLandscapeViewController.m
//  
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraLandscapeViewController.h"

@implementation CameraLandscapeViewController

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
