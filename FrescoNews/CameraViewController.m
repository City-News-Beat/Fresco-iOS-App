//
//  CameraViewController.m
//  
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraViewController.h"
@import AVFoundation;
@import AssetsLibrary;
@import ImageIO;
#import "FRSTabBarController.h"
#import "CameraPreviewView.h"
#import "CTAssetsPickerController.h"
#import "AppDelegate.h"
#import "CLLocation+EXIFGPS.h"
#import "ALAsset+assetType.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "MKMapView+Additions.h"

@implementation TemplateCameraViewController
// Do not delete
@end

typedef enum : NSUInteger {
    CameraModePhoto,
    CameraModeVideo
} CameraMode;

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

// TODO: Upgrade to PHPhotoLibrary in app version 2.1
@interface CameraViewController () <AVCaptureFileOutputRecordingDelegate, CTAssetsPickerControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet CameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *apertureButton;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UILabel *broadcastLabel;
@property (weak, nonatomic) IBOutlet UIView *broadcastStatus;
@property (weak, nonatomic) IBOutlet UIView *doneButtonBackground;
@property (weak, nonatomic) IBOutlet UILabel *assignmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *pleaseRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pleaseDisableLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlViewWidthConstraint;
@property (strong, nonatomic) NSMutableArray *createdAssetURLs;

// Refactor
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) FRSAssignment *defaultAssignment;
@property (nonatomic) BOOL withinRangeOfDefaultAssignment;

// Session management
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation CameraViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videoButton.selected = YES; // TODO: Persist this and other camera state
    [self updateCameraMode:CameraModeVideo];
    self.createdAssetURLs = [NSMutableArray new];
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];

    // Prevent conflict between background music and camera
    session.automaticallyConfiguresApplicationAudioSession = NO;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    // Setup the preview view
    [[self previewView] setSession:session];

    // Check for device authorization
    [self checkDeviceAuthorizationStatus];

    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).

    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];

    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];

        NSError *error = nil;

        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];

        if (error) {
            NSLog(@"%@", error);
        }

        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];

            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.

                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }

        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];

        if (error) {
            NSLog(@"%@", error);
        }

        if ([session canAddInput:audioDeviceInput]) {
            [session addInput:audioDeviceInput];
        }

        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput]) {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            [self setMovieFileOutput:movieFileOutput];
        }

        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput]) {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.view.hidden = NO;
    self.controlViewWidthConstraint.constant = 0.3 * self.view.frame.size.width;

    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];

        __weak CameraViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CameraViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
            });
        }]];
        [[self session] startRunning];
    });

    // TODO: Confirm permissions
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];

    [self updateRecentPhotoView];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];

        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });

    [self.locationManager stopUpdatingLocation];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation when no access to camera or when recording is in progress
    return self.isDeviceAuthorized && ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.isDeviceAuthorized ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];

        if (isCapturingStillImage) {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext) {
        //
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext) {
        //
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Suppress UI animation on interface rotation
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // You could make a call to update constraints based on the new orientation here.
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [CATransaction commit];
        [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)self.interfaceOrientation];
    }];
}

#pragma mark - Actions

- (IBAction)apertureButtonTapped:(id)sender
{
    if (self.photoButton.selected) {
        [self snapStillImage];
    }
    else {
        [self toggleMovieRecording];
    }
}

- (void)showUIForCameraMode:(CameraMode)cameraMode
{
    self.controlsView.backgroundColor = [UIColor whiteColor];
    self.apertureButton.backgroundColor = [UIColor colorWithHex:@"E6BE2E"];

    if (cameraMode == CameraModeVideo) {
        [self.apertureButton setBackgroundImage:[UIImage imageNamed:@"video-shutter-icon"] forState:UIControlStateNormal];
    }

    for (UIView *view in [self.controlsView subviews]) {
        view.hidden = NO;
    }
    self.activityIndicator.hidden = YES;
}

- (void)hideUIForCameraMode:(CameraMode)cameraMode
{
    // Hide most of the UI
    self.controlsView.backgroundColor = [UIColor clearColor];
    for (UIView *view in [self.controlsView subviews]) {
        view.hidden = YES;
    }

    self.apertureButton.hidden = NO;
    self.flashButton.hidden = NO;
    if (cameraMode == CameraModeVideo) {
        [self.apertureButton setBackgroundImage:[UIImage imageNamed:@"video-recording-icon"] forState:UIControlStateNormal];
    }

    self.apertureButton.backgroundColor = [UIColor clearColor];
}

- (void)toggleMovieRecording
{
    if ([[self movieFileOutput] isRecording]) {
        [self showUIForCameraMode:CameraModeVideo];
        [self.activityIndicator startAnimating];
        self.doneLabel.hidden = YES;
        self.doneButton.enabled = NO;

        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
        [[AVAudioSession sharedInstance] setActive:YES
                                             error: nil];
    }
    else {
        [self hideUIForCameraMode:CameraModeVideo];

        // Stops background audio
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES
                                             error:nil];
    }

    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording]) {
            [self setLockInterfaceRotation:YES];

            AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
            item.keySpace = AVMetadataKeySpaceCommon;
            item.key = AVMetadataCommonKeyLocation;
            item.value = [NSString stringWithFormat:@"%+08.4lf%+09.4lf/", self.location.coordinate.latitude, self.location.coordinate.longitude];
            self.movieFileOutput.metadata = @[item];

            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }

            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];

            // Turning OFF flash for video recording
            [self setTorchMode:(self.flashButton.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff)];

            NSError *writeError = nil;
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:&writeError];
            }

            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else {
            [[self movieFileOutput] stopRecording];
            [self setTorchMode:AVCaptureTorchModeOff];
        }
    });
}

- (void)snapStillImage
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];

        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                NSMutableDictionary *metadata = [[self.location EXIFMetadata] mutableCopy];

                // There may be a more correct way to do this
                NSString *assignmentID = [NSString stringWithFormat:@"FrescoAssignmentID=%@", self.defaultAssignment.assignmentId];

                NSDictionary *frescoDict = @{ (NSString *)kCGImagePropertyExifUserComment : assignmentID };
                [metadata setObject:frescoDict forKey:(NSString *)kCGImagePropertyExifDictionary];

                // magic numbers...
                AVCaptureVideoOrientation captureOrientation = [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation];
                NSInteger CGImagePropertyOrientation = 3; // AVCaptureVideoOrientationLandscapeLeft
                if (captureOrientation == AVCaptureVideoOrientationLandscapeRight) {
                    CGImagePropertyOrientation = 1;
                }
                [metadata setObject:@(CGImagePropertyOrientation) forKeyedSubscript:(NSString *)kCGImagePropertyOrientation];

                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage]
                                                                    metadata:metadata
                                                             completionBlock:^(NSURL *assetURL, NSError *error) {
                                                                 [self.createdAssetURLs addObject:assetURL];
                                                             }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideUIForCameraMode:CameraModePhoto];
                    [self showUIForCameraMode:CameraModePhoto];
                    [self updateRecentPhotoView:image];
                });
            }
        }];
    });
}

// TODO: Ask if we want to keep this or not
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self cancel];
}

- (IBAction)flashButtonTapped:(UIButton *)button
{
    button.selected = !button.selected;
    [CameraViewController setFlashMode:(button.selected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff) forDevice:[[self videoDeviceInput] device]];

    dispatch_async([self sessionQueue], ^{
        if ([[self movieFileOutput] isRecording]) {
            [self setTorchMode:(button.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff)];
        }
    });
}

- (void)cancel
{
    [self cancelAndReturnToPreviousTab:YES];
}

- (void)cancelAndReturnToPreviousTab:(BOOL)returnToPreviousTab
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [VariableStore resetDraftGalleryPost];
    
    FRSTabBarController *vc = ((FRSRootViewController *)self.presentingViewController).tbc;
    vc.tabBar.hidden = NO;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
        vc.selectedIndex = returnToPreviousTab ? [[NSUserDefaults standardUserDefaults] integerForKey:@"previouslySelectedTab"] : 4 /* profile tab */;
    }];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = (CGPoint){0.5, 0.5};
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (IBAction)modeButtonTapped:(UIButton *)button
{
    if (!button.selected) {
        button.selected = YES;

        if (button.tag) {
            self.photoButton.selected = NO;
            [self updateCameraMode:CameraModeVideo];
        }
        else {
            self.videoButton.selected = NO;
            [self updateCameraMode:CameraModePhoto];
        }
    }
}

- (IBAction)doneButtonTapped:(id)sender
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.title =  @"Choose Media";
    picker.autoSubmit = (sender ? NO : YES);
    picker.createdAssetURLs = self.createdAssetURLs;
    self.view.hidden = YES;
    [self presentViewController:picker animated:(sender ? YES : NO) completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSString *)temporaryPathForImage:(UIImage *)image
{
    NSData *jpegImageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *photoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"photo" stringByAppendingPathExtension:@"jpeg"]];

    NSError *writeError = nil;
    if (![jpegImageData writeToFile:photoPath options:NSDataWritingFileProtectionNone error:&writeError]) {
        [jpegImageData writeToFile:photoPath atomically:NO];
    }

    return photoPath;
}

#pragma mark - File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error);
    }

    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];

    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.doneLabel.hidden = NO;
        self.doneButton.enabled = YES;

        if (error) {
            NSLog(@"%@", error);
        }
        else {
            [self.createdAssetURLs addObject:assetURL];
        }

        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];

        if (backgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }
    }];
}

#pragma mark - Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    if (![[[self videoDeviceInput] device] hasTorch]) {
        return;
    }

    AVCaptureDevice *device = [[self videoDeviceInput] device];
    if ([device isTorchModeSupported:torchMode] && [device torchMode] != torchMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:torchMode];
            [device unlockForConfiguration];
        }
        else {
            // TODO: Deal with the error
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            NSLog(@"trying to animate... (broken for some reason?)");
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {
            self.deviceAuthorized = YES;
            self.pleaseRotateLabel.text = @"Please rotate your phone";
            self.pleaseDisableLabel.text = @"Also, please disable orientation lock (if set)";
        }
        else {
            self.deviceAuthorized = NO;
            self.pleaseRotateLabel.text = @"No permission to use the camera";
            self.pleaseDisableLabel.text = @"Please change your privacy settings";
        }
    }];
}

- (void)updateCameraMode:(CameraMode)cameraMode
{
    if (cameraMode == CameraModePhoto) {
        [self.apertureButton setBackgroundImage:[UIImage imageNamed:@"camera-aperture-icon"] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"flash-off.png"] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"flash-on.png"] forState:UIControlStateSelected];
        // self.broadcastStatus.hidden = YES;
    }
    else {
        [self.apertureButton setBackgroundImage:[UIImage imageNamed:@"video-shutter-icon"] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"torch-off.png"] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"torch-on.png"] forState:UIControlStateSelected];
        // self.broadcastStatus.hidden = NO;
    }
}

- (void)updateRecentPhotoView
{
    [self updateRecentPhotoView:nil];
}

- (void)updateRecentPhotoView:(UIImage *)image
{
    if (image) {
        [self.doneButton setImage:image forState:UIControlStateNormal];
        return;
    }

    // Grab the most recent image from the photo library
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (group) {
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *innerStop) {
                                             if ([asset valueForProperty:ALAssetPropertyLocation]) {
                                                 [self.doneButton setImage:[UIImage imageWithCGImage:[asset thumbnail]] forState:UIControlStateNormal];
                                                 *innerStop = YES;
                                             }
                                         }];
                                     }
                                 }
                               failureBlock:^(NSError *error) {
                                   NSLog(@"error: %@", error);
                               }];
}

- (void)configureAssignmentLabel
{
    if (self.defaultAssignment) {
        CGFloat distanceInMiles = [self.location distanceFromLocation:self.defaultAssignment.locationObject] / kMetersInAMile;
        self.withinRangeOfDefaultAssignment = (distanceInMiles < [self.defaultAssignment.radius floatValue]);
    }
    else {
        self.withinRangeOfDefaultAssignment = NO;
    }

    if (self.withinRangeOfDefaultAssignment) {
        self.assignmentLabel.hidden = NO;
        NSString *assignmentString = self.defaultAssignment.title;

        // Leave lame leading and trailing space
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  In range of %@  ", assignmentString]];

        [string setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0]}
                        range:(NSRange){14, [string length] - 14}];
        self.assignmentLabel.attributedText = string;
    }

    [UIView animateWithDuration:0.5 animations:^{
        self.assignmentLabel.alpha = self.withinRangeOfDefaultAssignment ? 0.75 : 0.0;
    } completion:^(BOOL finished) {
        if (!self.withinRangeOfDefaultAssignment) {
            self.assignmentLabel.hidden = YES;
        }
    }];
}

#pragma mark - CTAssetsPickerControllerDelegate methods

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    [self cancel];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {} // required by protocol

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    return picker.selectedAssets.count < 10;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAsset:(ALAsset *)asset
{
    NSString *mimeType = [asset mimeType];
    if (![mimeType isEqualToString:@"image/jpeg"] && ![mimeType isEqualToString:@"video/quicktime"]) {
        return NO;
    }

#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    // Suspenders
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    if ([date timeIntervalSinceDate:[NSDate date]] < [VariableStore sharedInstance].maximumAssetAge) {
        return NO;
    }

    if ([asset valueForProperty:ALAssetPropertyLocation]) {
        return YES;
    }

    return NO;
#endif
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) <= [VariableStore sharedInstance].maximumVideoLength;
    }

    return YES;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    // Set All Photos as default album and it will be shown initially.
    return [[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAssetsGroup:(ALAssetsGroup *)group
{
    // Do not show empty albums
    return group.numberOfAssets > 0;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // TODO: Make this smarter
        [self findNearbyAssignments];
    });

    [self configureAssignmentLabel];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // TODO: Also check for kCLAuthorizationStatusAuthorizedAlways
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access to Location Disabled"
                                                        message:[NSString stringWithFormat:@"To re-enable, go to Settings and turn on Location Service for the %@ app.", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)findNearbyAssignments
{
    // TODO: Add support for expiring/expired assignments
    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:100 ofLocation:self.location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
        self.defaultAssignment = [responseObject firstObject];
    }];
}

@end
