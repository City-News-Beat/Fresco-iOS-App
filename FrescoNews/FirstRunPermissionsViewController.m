//
//  FirstRunPermissionsViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunPermissionsViewController.h"
@import CoreLocation;
@import AVFoundation;
@import Photos;
#import "AppDelegate.h"

@interface FirstRunPermissionsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cameraPermissionsImage;
@property (weak, nonatomic) IBOutlet UIImageView *locationPermissionsImage;
@property (weak, nonatomic) IBOutlet UIImageView *notificationsPermissionsImage;
@property (weak, nonatomic) IBOutlet UIButton *cameraPermissionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationPermissionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationsPermissionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *skipFeatureButton;
@property (weak, nonatomic) IBOutlet UIImageView *progressBarImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation FirstRunPermissionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isSkipState = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)tempToggle:(id)sender
{
    if (self.isSkipState == NO) {
        [self loadAsSkipScreen];
        self.isSkipState = YES;
    }
    else {
        [self loadAsPermissionsScreen];
        self.isSkipState = NO;
    }
}

- (void)loadAsSkipScreen
{
    [[self actionButton] setTitle:@"Done" forState:UIControlStateNormal];
    self.progressBarImage.hidden = YES;
    self.skipFeatureButton.hidden = NO;
}

- (void)loadAsPermissionsScreen
{
    [[self actionButton] setTitle:@"Next" forState:UIControlStateNormal];
    self.progressBarImage.hidden = NO;
    self.skipFeatureButton.hidden = YES;
}

- (IBAction)cameraButtonTapped:(id)sender
{
    [self requestCameraAuthorization];
    [self requestMicrophoneAuthorization];
    [self requestCameraRollAuthorization];
}

- (IBAction)enableLocationButtonTapped:(id)sender
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    // If the user declines, prompt the user (at some point) to approve "when in use" location tracking - manually!
}

- (IBAction)enableNotificationsTapped:(id)sender
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate registerForPushNotifications];
}

- (IBAction)actionNext:(id)sender
{
    [self performSegueWithIdentifier:@"showRadius" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRadius"]) {
    }
}

#pragma mark - Request authorization methods

- (void)requestCameraAuthorization
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {}
    else if (status == AVAuthorizationStatusDenied) {}
    else if (status == AVAuthorizationStatusRestricted) {}
    else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) {
                // TODO: Complain?
                self.cameraPermissionsImage.image = [UIImage imageNamed:@"cameraOnIcon"];
                [self.cameraPermissionsLabel setTitle:@"Camera Enabled" forState:UIControlStateNormal];
            }
        }];
    }
}

- (void)requestMicrophoneAuthorization
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            // TODO: Complain?
        }
    }];
}

- (void)requestCameraRollAuthorization
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                break;
            case PHAuthorizationStatusRestricted:
                // TODO
                break;
            case PHAuthorizationStatusDenied:
                // TODO
                break;
            default:
                break;
        }
    }];
}

@end
