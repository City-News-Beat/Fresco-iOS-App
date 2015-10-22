//
//  FirstRunPermissionsViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import CoreLocation;
@import AVFoundation;
@import Photos;
@import AssetsLibrary;

#import "FirstRunPermissionsViewController.h"
#import "AppDelegate.h"

@interface FirstRunPermissionsViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cameraPermissionsImage;
@property (weak, nonatomic) IBOutlet UIButton *locationPermissionsImage;
@property (weak, nonatomic) IBOutlet UIButton *notificationsPermissionsImage;

@property (weak, nonatomic) IBOutlet UIButton *cameraPermissionsLabel; // rename these to "button"
@property (weak, nonatomic) IBOutlet UIButton *locationPermissionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationsPermissionsLabel;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation FirstRunPermissionsViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (IBAction)cameraButtonTapped:(UIButton *)button
{
    button.enabled = NO;
    // Don't change the order without testing - see -requestCameraRollAuthorization below
    [self requestCameraAuthorization];
    [self requestMicrophoneAuthorization];
    [self requestCameraRollAuthorization];
}

- (IBAction)enableLocationButtonTapped:(UIButton *)button
{
    button.enabled = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            [self.locationPermissionsImage setImage:[UIImage imageNamed:@"locationOnIcon"] forState:UIControlStateSelected];
            [self.locationPermissionsLabel setTitle:LOC_ENABLED forState:UIControlStateNormal];
        }
        else {
            [self.locationPermissionsLabel setTitle:LOC_DISABLED forState:UIControlStateNormal];
        }
    });
}

- (IBAction)enableNotificationsTapped:(UIButton *)button
{
    button.enabled = NO;
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [appDelegate registerForPushNotifications];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.notificationsPermissionsLabel setTitle:NOTIF_PENDING forState:UIControlStateNormal];
    
    });
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(confirmPushNotifications:) userInfo:nil repeats:YES];
}

- (void)confirmPushNotifications:(NSTimer *)timer
{
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        
        [timer invalidate];
        timer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.notificationsPermissionsImage setBackgroundImage:[UIImage imageNamed:@"notificationOnIcon"] forState:UIControlStateNormal];;
            [self.notificationsPermissionsLabel setTitle:NOTIF_ENABLED forState:UIControlStateNormal];
        });
    }
}

- (IBAction)actionNext:(id)sender
{
    [self performSegueWithIdentifier:SEG_SHOW_RADIUS sender:self];
}

#pragma mark - Request authorization methods

- (void)requestCameraAuthorization
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {}
    else if (status == AVAuthorizationStatusDenied) {}
    else if (status == AVAuthorizationStatusRestricted) {}
    else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
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
                [self updateCameraButton];
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

- (void)updateCameraButton
{
    // All of camera, microphone, and camera roll authorizations must be granted for "Camera Enabled" status
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized &&
                // [AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted && // on hold pending a good way to test
                [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized)
        {
            [self.cameraPermissionsImage setBackgroundImage:[UIImage imageNamed:@"cameraOnIcon"] forState:UIControlStateNormal];
            [self.cameraPermissionsLabel setTitle:CAMERA_ENABLED forState:UIControlStateNormal];
        }
        else {
            [self.cameraPermissionsLabel setTitle:CAMERA_DISABLED forState:UIControlStateNormal];
        }
        
    });
}


@end
