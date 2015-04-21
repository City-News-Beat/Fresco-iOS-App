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
    [self setupToolbar];
    self.title = @"Create a Gallery Post";
}

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(returnToCamera:)];
}

- (void)setupToolbar
{
    self.toolbarItems = [self toolbarItems];
}

- (void)returnToCamera:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"Send to Fresco"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(submitGalleryPost:)];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title = [self titleButtonItem];
    UIBarButtonItem *space = [self spaceButtonItem];
    return @[space, title, space];
}

- (void)submitGalleryPost:(id)sender
{
    
}

@end
