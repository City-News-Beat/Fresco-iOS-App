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
@import AssetsLibrary;
#import "AppDelegate.h"

@interface FirstRunPermissionsViewController () <CLLocationManagerDelegate, FRSBackButtonDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *cameraPermissionsImage;
@property (weak, nonatomic) IBOutlet UIImageView *locationPermissionsImage;
@property (weak, nonatomic) IBOutlet UIImageView *notificationsPermissionsImage;
@property (weak, nonatomic) IBOutlet UIButton *cameraPermissionsLabel; // rename these to "button"
@property (weak, nonatomic) IBOutlet UIButton *locationPermissionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationsPermissionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *skipFeatureButton;
@property (weak, nonatomic) IBOutlet UIImageView *progressBarImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation FirstRunPermissionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isSkipState = YES;
    self.cameraPermissionsImage.alpha = 0.54;
    self.locationPermissionsImage.alpha = 0.54;
    self.notificationsPermissionsImage.alpha = 0.54;
    
    [self initBackButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    FRSBackButton *backButton = (FRSBackButton *)[self.view viewWithTag:10];
    backButton.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    FRSBackButton *backButton = (FRSBackButton *)[self.view viewWithTag:10];
    backButton.delegate = nil;
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
    [[self actionButton] setTitle:DONE forState:UIControlStateNormal];
    self.progressBarImage.hidden = YES;
    self.skipFeatureButton.hidden = NO;
}

- (void)loadAsPermissionsScreen
{
    [[self actionButton] setTitle:NEXT forState:UIControlStateNormal];
    self.progressBarImage.hidden = NO;
    self.skipFeatureButton.hidden = YES;
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
    // If the user declines, prompt the user (at some point) to approve "when in use" location tracking - manually!
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            self.locationPermissionsImage.image = [UIImage imageNamed:@"locationOnIcon"];
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
            self.notificationsPermissionsImage.image = [UIImage imageNamed:@"notificationOnIcon"];
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
            self.cameraPermissionsImage.image = [UIImage imageNamed:@"cameraOnIcon"];
            [self.cameraPermissionsLabel setTitle:CAMERA_ENABLED forState:UIControlStateNormal];
        }
        else {
            [self.cameraPermissionsLabel setTitle:CAMERA_DISABLED forState:UIControlStateNormal];
        }
    });
}



- (void)initBackButton {
    
    FRSBackButton *backButton = [[FRSBackButton alloc] initWithFrame:CGRectMake(12, 24, 70, 40)];
    
    [self.view addSubview:backButton];
    
    backButton.delegate = self;
    
    backButton.tag = 10;
    
}


- (void)backButtonTapped {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
