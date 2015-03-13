//
//  CameraViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraViewControllerLandscape.h"

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.parentViewController presentViewController:[[CameraViewControllerLandscape alloc] init] animated:NO completion:nil];
}

@end
