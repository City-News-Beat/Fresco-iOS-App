//
//  CameraViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraLandscapeViewController.h"

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CameraLandscapeViewController *vc = (CameraLandscapeViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"cameraLandscapeVC"];
    [self.parentViewController presentViewController:vc animated:NO completion:nil];
}

@end
