//
//  CameraLandscapeViewController.m
//  
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraLandscapeViewController.h"

@interface CameraLandscapeViewController ()
@property (strong, nonatomic) UIImagePickerController *picker;
@end

@implementation CameraLandscapeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.picker.sourceType = sourceType;
    self.picker.delegate = self;
    [self presentViewController:self.picker animated:NO completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
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
