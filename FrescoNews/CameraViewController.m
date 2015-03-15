//
//  CameraViewController.m
//  
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraViewController.h"
#import "TabBarController.h"

@interface CameraViewController ()
@property (nonatomic) BOOL dismiss;
@end

@implementation CameraViewController

#define CAMERA_TRANSFORM 1.3

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.dismiss) {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        TabBarController *vc = ((TabBarController *)self.presentingViewController);
        vc.selectedIndex = vc.savedIndex;
        vc.tabBar.hidden = NO;
    }
    else {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = sourceType;
    picker.showsCameraControls = NO;
    picker.delegate = self;
    picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_TRANSFORM, CAMERA_TRANSFORM);
    picker.cameraOverlayView = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] firstObject];
    [self presentViewController:picker animated:NO completion:nil];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    self.dismiss = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UIViewController methods

//- (BOOL)shouldAutorotate
//{
//    return NO;
//}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeRight;
//}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
