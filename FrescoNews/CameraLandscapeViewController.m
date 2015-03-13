//
//  CameraLandscapeViewController.m
//  
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraLandscapeViewController.h"

@interface CameraLandscapeViewController ()
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation CameraLandscapeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}

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
