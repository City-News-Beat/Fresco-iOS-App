//
//  GalleryPostViewController.m
//  FrescoNews
//
//  Created by Joshua Lerner on 4/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryPostViewController.h"

@implementation GalleryPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    self.title = @"Create a Gallery Post";
}

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(returnToCamera:)];
}

- (void)returnToCamera:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
