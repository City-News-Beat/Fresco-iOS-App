//
//  CameraViewController.m
//  
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraViewController.h"
#import "TabBarController.h"

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) BOOL dismiss;
@end

@implementation CameraViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dismiss) {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        ((UITabBarController *)self.presentingViewController).selectedIndex = ((TabBarController *)self.presentingViewController).savedIndex;
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
    picker.cameraOverlayView = self.overlayView; // TODO: Move self.overlayView to xib

    [self presentViewController:picker animated:NO completion:^{
        picker.cameraOverlayView.frame = self.view.frame;
    }];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:NO completion:nil];
    self.dismiss = YES;
}

#pragma mark - UIViewController methods

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
