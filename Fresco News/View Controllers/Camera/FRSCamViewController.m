//
//  CameraViewController.m
//  
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;
@import Photos;

#import "AssetsPickerController.h"
#import "UIViewController+Additions.h"
#import "FRSCamViewController.h"
#import "FRSTabBarController.h"
#import "CameraPreviewView.h"
#import "AppDelegate.h"
#import "CLLocation+EXIFGPS.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "MKMapView+Additions.h"
#import "GalleryPostViewController.h"
#import "BaseNavigationController.h"
#import "FRSMotionManager.h"
#import "FRSUploadManager.h"
#import "FRSLocationManager.h"

#import "FRSGalleryAssetsManager.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

typedef enum : NSUInteger {
    CameraModePhoto,
    CameraModeVideo
} CameraMode;

typedef NS_ENUM( NSInteger, FRSCamSetupResult ) {
    FRSCamSetupResultSuccess,
    FRSCamSetupResultCameraNotAuthorized,
    FRSCamSetupResultSessionConfigurationFailed
};

@interface FRSCamViewController () <AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate, FRSMotionMangerDelegate>

@property (weak, nonatomic) IBOutlet CameraPreviewView *previewView;

//Buttons
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *apertureButton;

//UIViews
@property (weak, nonatomic) IBOutlet UIView *cancelButtonTapView;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIImageView *doneButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rotateImageView;
@property (weak, nonatomic) IBOutlet UILabel *assignmentLabel;

@property (strong, nonatomic) CAShapeLayer *circleLayer;

@property (strong, nonatomic) FRSAssignment *defaultAssignment;

// Session management
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, assign) BOOL capturingStilImage;


/**
 *  Tells us if the camera is in the correct orientation
 */

@property (nonatomic) BOOL isCorrectOrientation;


// Utilities
@property (nonatomic) FRSCamSetupResult setupResult;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic, strong) NSTimer *videoTimer;
@property (nonatomic, strong) NSTimer *locationTimer;

@end

@implementation FRSCamViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.isPresented = YES;
    }
    return self;
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self configureUIElements];
    
    // Create the AVCaptureSession.
    self.session = [[AVCaptureSession alloc] init];
    
    // Setup the preview view.
    self.previewView.session = self.session;
    
    // Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    self.setupResult = FRSCamSetupResultSuccess;

    // Check for device authorization
    // Check video authorization status. Video access is required and audio access is optional.
    // If audio access is denied, audio is not recorded during movie recording.
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = FRSCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.setupResult = FRSCamSetupResultCameraNotAuthorized;
            break;
        }
    }

    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async(self.sessionQueue, ^{
        
        if ( self.setupResult != FRSCamSetupResultSuccess ) {
            return;
        }
        
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [FRSCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
        [self.session beginConfiguration];
        
        if ([self.session canAddInput:videoDeviceInput] ) {
            
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                // can only be manipulated on the main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                // -[viewWillTransitionToSize:withTransitionCoordinator:].
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                previewLayer.connection.videoOrientation = initialVideoOrientation;
                
            });
        }
        else {
            NSLog( @"Could not add video device input to the session" );
            self.setupResult = FRSCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if ( [self.session canAddInput:audioDeviceInput] ) {
            [self.session addInput:audioDeviceInput];
        }
        else {
            NSLog( @"Could not add audio device input to the session" );
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ( [self.session canAddOutput:movieFileOutput] ) {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( connection.isVideoStabilizationSupported ) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
        }
        else {
            NSLog( @"Could not add movie file output to the session" );
            self.setupResult = FRSCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ( [self.session canAddOutput:stillImageOutput] ) {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            [self.session addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        }
        else {
            NSLog( @"Could not add still image output to the session" );
            self.setupResult = FRSCamSetupResultSessionConfigurationFailed;
        }
        
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        [self.session commitConfiguration];
        
    //End session thread
    });
    
    
    [[FRSGalleryAssetsManager sharedManager] fetchGalleryAssetsInBackgroundWithCompletion:nil];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    //Restart location manager updating
    [[FRSLocationManager sharedManager] setupLocationMonitoringForState:LocationManagerStateForeground];
    [FRSLocationManager sharedManager].stopLocationUpdates = NO;
    [FRSLocationManager sharedManager].delegate = self;
    
    
    //Start tracking movement via the FRSMotionManager (acceleromotor)
    [[FRSMotionManager sharedManager] startTrackingMovement];
    [FRSMotionManager sharedManager].delegate = self;
    
    // Orientation notification set up
    ///Call update block to check for orientation on load
    [self orientationDidChange];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            
            BOOL authorized = status == PHAuthorizationStatusAuthorized? YES : NO;
            
            [self configureDoneButtonAndImageViewForAuthorized:authorized];
            
        }];
        
    });
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    dispatch_async(self.sessionQueue, ^{

        
        switch ( self.setupResult )
        {
            case FRSCamSetupResultSuccess:
            {
                // Only setup observers and start the session running if setup succeeded.
                [self addObservers];
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //Fade in the preview layer for smooth transition
                    if(self.previewView.alpha == 0){
                        
                        [UIView animateWithDuration:.4 animations:^{
                            self.previewView.alpha = 1;
                        }];
                        
                    }
                });
                break;
            }
            case FRSCamSetupResultCameraNotAuthorized:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alertCon = [FRSAlertViewManager
                                                   alertControllerWithTitle:@"Can't use your camera!"
                                                   message:@"Fresco doesn't have permission to use the camera, please change privacy settings"
                                                   action:DISMISS handler:nil];
                    
                    [alertCon addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        
                    }]];
                    
                    [self presentViewController:alertCon animated:YES completion:nil];
                    
                });
                break;
            }
            case FRSCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                    [self presentViewController:[FRSAlertViewManager
                                                 alertControllerWithTitle:@"Some issues with your camera"
                                                 message:@"We were unable to capture photos or videos. Please check your app settings in order to enable your camera."
                                                 action:DISMISS handler:nil]
                                       animated:YES
                                     completion:nil];
                });
                break;
            }
        }
    });
}

- (void)viewDidDisappear:(BOOL)animated{
    
    //Stop the session from running when leaving the view
    dispatch_async(self.sessionQueue, ^{
        if (self.setupResult == FRSCamSetupResultSuccess) {
            [self.session stopRunning];
            [self removeObservers];
        }
    });
    
    [super viewDidDisappear:animated];
    
    //Clear all the timers so they don't re-run
    [self.videoTimer invalidate];
    self.videoTimer = nil;
    
    [self.locationTimer invalidate];
    self.locationTimer = nil;
}

/**
 *  General method to set up initial state of UI elements
 */

-(void)configureUIElements{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /* Assignment Label */
        self.assignmentLabel.alpha = 0;
        
        self.doneButton.clipsToBounds = YES;
        self.doneButton.layer.cornerRadius = 8;
        
        self.doneButton.backgroundColor = [UIColor clearColor];
        [self.doneButton setTitle:@"" forState:UIControlStateNormal];
        
        self.doneButtonImageView.clipsToBounds = YES;
        self.doneButtonImageView.layer.cornerRadius = self.doneButton.layer.cornerRadius;
        self.doneButtonImageView.layer.borderWidth = 0.5;
        self.doneButtonImageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.12].CGColor;
        self.doneButtonImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doneButtonTapped:)];
        [self.doneButtonImageView addGestureRecognizer:gr];
        
        //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
        [self.cancelButtonTapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAndReturnToPreviousTab)]];
        
        //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
        [self.rotateImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateRotateImageView:)]];
    });
}


/**
 *  Checks the results of the assets fetch and appropriate configures the states of both the done button and the imageview
 *
 *  @param authorized If the user has authorized photos access
 */

-(void)configureDoneButtonAndImageViewForAuthorized:(BOOL)authorized{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!authorized){
            
            self.doneButtonImageView.alpha = 1.0;
            self.doneButtonImageView.image = [UIImage imageNamed:@"camera-roll"];
            self.doneButton.alpha = 0.0;
            return;
        
        }
        
        PHFetchResult *result = [FRSGalleryAssetsManager sharedManager].fetchResult;
        if (result.count){
            PHAsset *asset = [result firstObject];
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.doneButtonImageView.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                self.doneButtonImageView.alpha = 1.0;
                self.doneButtonImageView.image = result;
            }];
        }
        else {
            self.doneButtonImageView.alpha = 0.0;
            self.doneButton.alpha = 0.0;
        }
    });
}

#pragma mark KVO and Notifications

/**
 *  Adds neccessary observers for camera
 */

- (void)addObservers
{
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:CapturingStillImageContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
    // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
    // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
    // interruption reasons.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

/**
 *  Removes all added oberservers
 */

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    @try {
        [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
        [self.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage" context:CapturingStillImageContext];
    }
    @catch (NSException *exception) {
        
    }

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext) {
        
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage) {
            
            [self runStillImageCaptureAnimation];
            
        }
        
    }
    else if (context == SessionRunningContext) {
        
        //        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        //
        //        dispatch_async( dispatch_get_main_queue(), ^{
        //             Only enable the ability to change camera if the device has more than one camera.
        //            self.cameraButton.enabled = isSessionRunning && ( [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1 );
        //            self.recordButton.enabled = isSessionRunning;
        //            self.stillButton.enabled = isSessionRunning;
        //        } );
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/**
 *  Notif listener for when subject area changes, then calls re-focus
 *
 *  @param notification
 */

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake( 0.5, 0.5 );
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if(self.isPresented)
        return UIInterfaceOrientationMaskLandscapeRight;
    
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - IB Actions

/**
 *  Selector for when clicking the aperture button
 *
 *  @param sender
 */

- (IBAction)apertureButtonTapped:(id)sender
{
    
    //Check if we're in the correct orientation
    if (self.isCorrectOrientation == YES) {
        
        //If we're in Photo mode
        if (self.photoButton.selected)
            [self snapStillImage];

        //If we're in Video mode
        else if(self.videoButton.selected)
            [self toggleMovieRecording];
        
    }
    //Animate the rotate image to indicate the device needs to be rotated
    else{
        
        [self animateRotateImageView:nil];
        
    }

}

/**
 *  Selector for when clicking the back arrow
 *
 *  @param sender
 */

- (IBAction)cancelButtonTapped:(id)sender
{
    [self cancelAndReturnToPreviousTab];
}

/**
 *  Select for when tapping on the flash button
 *
 *  @param button
 */

- (IBAction)flashButtonTapped:(UIButton *)button
{
    button.selected = !button.selected;

    dispatch_async([self sessionQueue], ^{
        
        [FRSCamViewController setFlashMode:(button.selected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff)
                                 forDevice:self.videoDeviceInput.device];
        
    });
}

/**
 *  Select for toggling between shooting states
 *
 *  @param button
 */

- (IBAction)modeButtonTapped:(UIButton *)button
{
    if (!button.selected) {
        
        button.selected = YES;
        
        if (button.tag == 50) {
            [self updateCameraMode:CameraModePhoto];
        }
        else if(button.tag == 51) {
            [self updateCameraMode:CameraModeVideo];
        }
    }
}

/**
 *  Selector to go to the media picker
 *
 *  @param sender
 */

- (IBAction)doneButtonTapped:(id)sender
{

    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:[[AssetsPickerController alloc] init]];

    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:navVC animated:NO completion:nil];

}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)self.previewView.layer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}


#pragma mark - UI Functions

- (void)showUIForCameraMode:(CameraMode)cameraMode
{
    
    if(cameraMode == CameraModeVideo){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [UIView animateWithDuration:.2 animations:^{
                
                // Hide most of the UI
                [self.circleLayer setOpacity:0];
                self.controlsView.backgroundColor = [UIColor whiteColor];
                [self.apertureButton setBackgroundColor:[UIColor goldApertureColor]];
                
                for (UIView *view in [self.controlsView subviews]) {
                    if(view != self.apertureButton){
                        view.alpha = 1;
                        view.userInteractionEnabled = YES;
                    }
                }
                
            } completion:^(BOOL finished){

                [self.circleLayer removeAnimationForKey:@"drawCircleAnimation"];
                [self.circleLayer removeFromSuperlayer];
                self.circleLayer = nil;
                
            }];
            
        });
        
    }
    
}

/**
 *  Hides UI for specific camera mod
 *
 *  @param cameraMode The camera mode to hide UI for
 */

- (void)hideUIForCameraMode:(CameraMode)cameraMode
{
    
    if(cameraMode == CameraModeVideo){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self runVideoRecordAnimation];
            
            [UIView animateWithDuration:.2 animations:^{
                
                // Hide most of the UI
                self.controlsView.backgroundColor = [UIColor clearColor];
                self.apertureButton.backgroundColor = [UIColor clearColor];
                
                for (UIView *view in [self.controlsView subviews]) {
                    if(view != self.apertureButton){
                        view.alpha = 0;
                        view.userInteractionEnabled = NO;
                    }
                }
                
            }];
            
        });
        
    }
    
}

/**
 *  Runs still image capture animation on aperture button
 */

- (void)runStillImageCaptureAnimation
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        //24 is the number of frames in the animation
        for (NSInteger i = 2; i < 25; i++)
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"shutter-%li",(long)i]]];
        
        for (NSInteger i = 24; i > 0; i--)
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"shutter-%li",(long)i]]];
        
        [self.apertureButton.imageView setAnimationImages:[images copy]];
        
        [self.apertureButton.imageView setAnimationDuration:.2];
        
        [self.apertureButton.imageView setAnimationRepeatCount:1];
        
        [self.apertureButton.imageView startAnimating];
        
        //fade in
        self.previewView.layer.opacity = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.previewView.layer.opacity = 1;
        }];
            
    });
    
}

/**
 *  Runs the video recording animation on the aperture button
 */

- (void)runVideoRecordAnimation{
    
    // Set up the shape of the circle
    int radius = 40;
    self.circleLayer = [CAShapeLayer layer];
    // Make a circular shape
    
    self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                       cornerRadius:radius].CGPath;
    // Center the shape in self.view
    self.circleLayer.position = CGPointMake(self.view.frame.size.width - CGRectGetMidX(self.apertureButton.frame) - radius,
                                            CGRectGetMidY(self.apertureButton.frame)-radius);
    
    // Configure the apperence of the circle
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = [UIColor redCircleStrokeColor].CGColor;
    self.circleLayer.lineWidth = 4;
    
    // Add to parent layer
    [self.view.layer addSublayer:self.circleLayer];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = MAX_VIDEO_LENGTH; //Animate ove max vid length
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // Add the animation to the circle
    [self.circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
}

/**
 *  Toggles camera mode between photo/camera, * performs animation and changes preset *
 *
 *  @param cameraMode The Camera Mode to switch to
 */

- (void)updateCameraMode:(CameraMode)cameraMode
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
            
        if (cameraMode == CameraModePhoto) {
            
            [UIView animateWithDuration:.2f animations:^{
                
                self.previewView.alpha = .0f;
                self.controlsView.alpha = 1;
                
                //Reset the preview view to its original frame
                if(self.previewView.savedBounds.size.width != 0) self.previewView.frame = self.previewView.savedBounds;
                
            } completion:^(BOOL finished){
                
 
                [self.session beginConfiguration];
                //Change the preset to display properly
                if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
                    //Set the session preset to photo, the default mode we enter in as
                    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
                }
                [self.session commitConfiguration];
                
                [self.apertureButton setImage:[UIImage imageNamed:@"shutter-1"] forState:UIControlStateNormal];
                
                self.videoButton.selected = NO;
                
                if(!self.photoButton.selected) self.photoButton.selected = YES;
                
                [UIView animateWithDuration:.2f animations:^{
                    
                    self.previewView.alpha = 1;
                    
                }];
                    

            }];
            
        }
        else if(cameraMode == CameraModeVideo) {
            
            //Save the bounds, so we can reset back to it later
            self.previewView.savedBounds = self.previewView.frame;
            
            [UIView animateWithDuration:.3f animations:^{
                
                self.previewView.alpha = .0f;
                self.controlsView.alpha = .7;
                
                //Scale the preview view to the whole screen
                self.previewView.frame = self.view.frame;
                
            } completion:^(BOOL finished){
                
                [self.session beginConfiguration];
                
                //Change the preset to display properly
                if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
                    //Set the session preset to photo, the default mode we enter in as
                    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
                }
                
                [self.session commitConfiguration];
                
                [self.apertureButton setImage:[UIImage imageNamed:@"video-recording-icon"] forState:UIControlStateNormal];
                
                self.photoButton.selected = NO;
                
                [UIView animateWithDuration:.2f animations:^{
                    self.previewView.alpha = 1;
                }];
                
            }];
        }
    });
}


/**
 *  Toggles the state of image preview
 *
 *  @param hidden Whether to hide the preview view or not
 *  @param image  Optional image to set as a placeholder
 */

- (void)toggleRecentPhotoViewWithImage:(UIImage *)thumbnail{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        self.doneButtonImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        if (thumbnail) {
            self.doneButtonImageView.alpha = 1.0;
            [self.doneButtonImageView setImage:thumbnail];
        }
        
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        self.doneButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.doneButtonImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.doneButton.alpha = 1.0f;
        } completion:nil];
    });
}

/**
 *  Configures the assignment banner with the current default assignment
 */

- (void)toggleAssignmentLabel:(BOOL)show
{
    
    if(!self.defaultAssignment)
        return;
    
    self.assignmentLabel.hidden = NO;
    
    if(show){
    
        NSString *assignmentString = [NSString stringWithFormat:@"   In range of %@   ", self.defaultAssignment.title];
        
        NSRange boldedRange = (NSRange){14, [assignmentString length] - 14};
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:assignmentString];
        
        [attrString beginEditing];
        [attrString addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:HELVETICA_NEUE_REGULAR size:11.0]
                           range:boldedRange];
        
        [attrString endEditing];
        
        self.assignmentLabel.attributedText = attrString;

    }
    
    if(!self.assignmentLabel.hidden){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                self.assignmentLabel.alpha = show ? 1.0f : 0.0f;
            } completion:^(BOOL finished) {
                if (!show) {
                    self.assignmentLabel.hidden = YES;
                }
            }];
            
        });
    
    }
}

/**
 *  Animates the rotate image view indicator
 *
 *  @param tapGestureRecognizer <#tapGestureRecognizer description#>
 */

- (void)animateRotateImageView:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [UIView animateWithDuration:.2 animations:^{
            
            float degrees = -15; //the value in degrees
            self.rotateImageView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
            
        } completion:^(BOOL finished){
            
            if(finished){
                
                [UIView animateWithDuration:.2 animations:^{
                    
                    self.rotateImageView.transform = CGAffineTransformMakeRotation(0);
                    
                }];
            }
            
        }];
        
    });
}

#pragma mark - Camera Actions

/**
 *  Toggles video recording
 */

- (void)toggleMovieRecording
{
    //Add for testing
    //if(self.controlsView.backgroundColor == [UIColor clearColor]){
    if ([[self movieFileOutput] isRecording]) {
        
        //Clear the timer so it doesn't re-run
        [self.videoTimer invalidate];
        self.videoTimer = nil;
        
        //Present UI for video
        [self showUIForCameraMode:CameraModeVideo];
        
        //Update the recent photo view
//        [self setRecentPhotoViewHidden:YES withImage:nil];

    }
    else {
        
        [self hideUIForCameraMode:CameraModeVideo];

        //Set up timer to disable video after maximumVideoLength seconds
        self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_VIDEO_LENGTH target:self selector:@selector(videoEnded:) userInfo:nil repeats:NO];
        
    }

    dispatch_async([self sessionQueue], ^{
        
        if (![[self movieFileOutput] isRecording]) {
            
            
            [FRSCamViewController setTorchMode:(self.flashButton.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff)
                                     forDevice:[[self videoDeviceInput] device]];
            
            AVCaptureConnection *movieConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (movieConnection.active) {

                AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
                item.keySpace = AVMetadataKeySpaceCommon;
                item.key = AVMetadataCommonKeyLocation;
                item.value = [NSString stringWithFormat:@"%+08.4lf%+09.4lf/", [FRSLocationManager sharedManager].location.coordinate.latitude, [FRSLocationManager sharedManager].location.coordinate.longitude];
                self.movieFileOutput.metadata = @[item];
            
                if ( [UIDevice currentDevice].isMultitaskingSupported ) {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                connection.videoOrientation = previewLayer.connection.videoOrientation;
                
                // Start recording to a temporary file.
                NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
                [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                
                [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                
            }
            
        }
        else {
            [[self movieFileOutput] stopRecording];
        }
        
    });
}

/**
 *  Captures still image
 */

- (void)snapStillImage
{
    dispatch_async(self.sessionQueue, ^{
        
        if(self.capturingStilImage)
            return;
        else
            self.capturingStilImage = YES;
        
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        
        // Update the orientation on the still image output video connection before capturing.
        connection.videoOrientation = previewLayer.connection.videoOrientation;
        
        // Capture a still image.
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
            
            self.capturingStilImage = NO;
            
            if (imageDataSampleBuffer ) {
                
                NSData *imageNSData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                CGImageSourceRef imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageNSData, NULL);
                
                //make the metadata dictionary mutable so we can add properties to it
                NSMutableDictionary *metadata = [(__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL) mutableCopy];
                
                NSMutableDictionary *GPSDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
                
                if(!GPSDictionary)
                    GPSDictionary = [[[FRSLocationManager sharedManager].location EXIFMetadata] mutableCopy];
                
                //Add the modified Data back into the image’s metadata
                if (GPSDictionary) {
                    [metadata setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
                }
                
                CFStringRef UTI = CGImageSourceGetType(imgSource); //this is the type of image (e.g., public.jpeg)
                
                //this will be the data CGImageDestinationRef will write into
                NSMutableData *newImageData = [NSMutableData data];
                
                CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1, NULL);
                
                if(!destination)
                    NSLog(@"***Could not create image destination ***");
                
                //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
                CGImageDestinationAddImageFromSource(destination, imgSource, 0, (__bridge CFDictionaryRef) metadata);
                
                //tell the destination to write the image data and metadata into our data object.
                //It will return false if something goes wrong
                BOOL success = NO;
                success = CGImageDestinationFinalize(destination);
                
                if(!success){
                    NSLog(@"***Could not create data from image destination ***");
                    return;
                }
                
                [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
                    
                    if (status == PHAuthorizationStatusAuthorized ) {
                        
                        // Note that creating an asset from a UIImage discards the metadata.
                        // In iOS 9, we can use -[PHAssetCreationRequest addResourceWithType:data:options].
                        // In iOS 8, we save the image to a temporary file and use +[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:].
                        if ([PHAssetCreationRequest class]) {
                            
                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                
                                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:newImageData options:nil];
                                
                            } completionHandler:^( BOOL success, NSError *error ) {
                                
                                if (!success) {
                                    NSLog( @"Error occurred while saving image to photo library: %@", error );
                                }
                                else {
                                    [self toggleRecentPhotoViewWithImage:[UIImage imageWithData:newImageData scale:.1]];
                                    
                                }
                            }];
                        }
                        else {
                            
                            NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
                            NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                            
                            NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
                            
                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                
                                NSError *error = nil;
                                
                                [newImageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                                
                                if ( error ) {
                                    NSLog( @"Error occured while writing image data to a temporary file: %@", error );
                                }
                                else {
                                    [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
                                }
                                
                            } completionHandler:^( BOOL success, NSError *error ) {
                                
                                if (!success ) {
                                    NSLog( @"Error occurred while saving image to photo library: %@", error );
                                }
                                else {
                                    [self toggleRecentPhotoViewWithImage:[UIImage imageWithData:newImageData scale:.1]];
                                    
                                }
                                
                                // Delete the temporary file.
                                [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
                                
                            }];
                        }
                    }
                }];
            }
            else {
                NSLog( @"Could not capture still image: %@", error );
            }
        }];
    });
}


/**
 *   Hides CameraViewController and reverts back to to TabBar interface
 */

- (void)cancelAndReturnToPreviousTab
{
    [[FRSUploadManager sharedManager] resetDraftGalleryPost];
    
    FRSTabBarController *tabBarController = ((FRSRootViewController *)self.presentingViewController).tbc;

    tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:UD_PREVIOUSLY_SELECTED_TAB];

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanup = ^{
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if ( currentBackgroundRecordingID != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    if ( error ) {
        NSLog( @"Movie file finishing error: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if ( success ) {
        // Check authorization status.
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if ( status == PHAuthorizationStatusAuthorized ) {
                // Save the movie file to the photo library and cleanup.
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    // In iOS 9 and later, it's possible to move the file into the photo library without duplicating the file data.
                    // This avoids using double the disk space during save, which can make a difference on devices with limited free disk space.
                    if ( [PHAssetResourceCreationOptions class] ) {
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                        options.shouldMoveFile = YES;
                        PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                        [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                    }
                    else {
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                        
                    }
                } completionHandler:^( BOOL success, NSError *error ) {
                    if ( ! success ) {
                        NSLog( @"Could not save movie to photo library: %@", error );
                    }
                    
                    [[FRSGalleryAssetsManager sharedManager] fetchGalleryAssetsInBackgroundWithCompletion:^{
                        PHAsset *asset = [[FRSGalleryAssetsManager sharedManager].fetchResult firstObject];
                        
                        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.doneButtonImageView.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
                            
                            [self toggleRecentPhotoViewWithImage:result];
                        }];
                        
                        cleanup();
                    }];
                    
                }];
            }
            else {
                cleanup();
            }
        }];
    }
    else {
        cleanup();
    }
}

#pragma mark - Device Configuration

- (void)viewTiltToLandscape:(NSNotification *)notification {
    
    if ([FRSMotionManager sharedManager].lastOrientation == UIInterfaceOrientationLandscapeRight) {
        
        if(self.rotateImageView.alpha != 0.0f){
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [UIView animateWithDuration:.2f animations:^{
                    self.rotateImageView.alpha = 0.0f;
                    
                }];
                
            });
        }

    } else {
        
        if(self.rotateImageView.alpha != 0.7f){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:.2f animations:^{
                    self.rotateImageView.alpha = 0.7f;
                    
                }];
                
            });
        }
    }
}

- (void)orientationDidChange{

    if([FRSMotionManager sharedManager].lastOrientation == UIInterfaceOrientationLandscapeRight) {
        
        self.isCorrectOrientation = YES;
        
        if (self.rotateImageView.alpha != 0.0f){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:.2f animations:^{
                    self.rotateImageView.alpha = 0.0f;
                }];
                
            });
        }
        
    }
    else {
        
        self.isCorrectOrientation = NO;
        
        if(self.rotateImageView.alpha != 0.7f){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:.2f animations:^{
                    self.rotateImageView.alpha = 0.7f;
                }];
                
            });
        }
    }
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode] ) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }
            
            if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode] ) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error.localizedDescription );
        }
    } );
}

/**
 *  Sets flash mode of capture device
 *
 *  @param flashMode The flash mode to set to
 *  @param device    The device to set
 */

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ( device.hasFlash && [device isFlashModeSupported:flashMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

/**
 *  Sets torch mode of capture device
 *
 *  @param flashMode The torch mode to set to
 *  @param device    The device to set
 */

+ (void)setTorchMode:(AVCaptureTorchMode)torchMode forDevice:(AVCaptureDevice *)device
{
    if ( device.hasTorch && [device isTorchModeSupported:torchMode] ) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error] ) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
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

#pragma mark - NSTimer Delegate and Selectors

- (void)videoEnded:(NSTimer *)timer{
    //End movie recording
    [self toggleMovieRecording];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [[FRSLocationManager sharedManager] stopUpdatingLocation];
    
    if([FRSLocationManager sharedManager].stopLocationUpdates)
        return;
    else
        [FRSLocationManager sharedManager].stopLocationUpdates = YES;
    
    if ([FRSLocationManager sharedManager].location && self.defaultAssignment == nil) {
        
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:20 ofLocation:[FRSLocationManager sharedManager].location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
                        
            if([responseObject firstObject] != nil){
                
                FRSAssignment *assignment = [responseObject firstObject];
                
                CGFloat distanceInMiles = [[FRSLocationManager sharedManager].location distanceFromLocation:assignment.locationObject] / kMetersInAMile;
                
                //Check if in range
                if(distanceInMiles < [assignment.radius floatValue]){
            
                    self.defaultAssignment = assignment;
                    
                    [self toggleAssignmentLabel:YES];
                    
                }
                
            }
            
        }];

    }
    
    //Set interval for location update every `locationUpdateInterval` seconds
    if (self.locationTimer == nil) {
        // NSLog(@"Starting timer...");
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:YES];
    }
}

/**
 *  Restarts location updates in defined interval
 */

- (void)restartLocationUpdates{
    
    if(self.defaultAssignment == nil){
        [[FRSLocationManager sharedManager]startUpdatingLocation];
        [FRSLocationManager sharedManager].stopLocationUpdates = NO;
    }
    else{
        [self.locationTimer invalidate];
        self.locationTimer = nil;
    }
}


@end
