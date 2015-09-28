//
//  CameraViewController.m
//  
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;
@import AssetsLibrary;
@import ImageIO;

#import "UIViewController+Additions.h"
#import "CameraViewController.h"
#import "FRSTabBarController.h"
#import "CameraPreviewView.h"
#import "CTAssetsPickerController.h"
#import "AppDelegate.h"
#import "CLLocation+EXIFGPS.h"
#import "ALAsset+assetType.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "MKMapView+Additions.h"
#import "FRSMotionManager.h"
#import "UIImage+ALAsset.h"

typedef enum : NSUInteger {
    CameraModePhoto,
    CameraModeVideo
} CameraMode;

// TODO: Upgrade to PHPhotoLibrary in app version 2.1
@interface CameraViewController () <AVCaptureFileOutputRecordingDelegate, CTAssetsPickerControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet CameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *cancelButtonTapView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *apertureButton;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UILabel *broadcastLabel;
@property (weak, nonatomic) IBOutlet UIView *broadcastStatus;
@property (weak, nonatomic) IBOutlet UIView *doneButtonBackground;
@property (weak, nonatomic) IBOutlet UIImageView *doneButtonImageView;
@property (weak, nonatomic) IBOutlet UILabel *assignmentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rotateImageView;
@property (weak, nonatomic) IBOutlet UILabel *pleaseRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pleaseDisableLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlViewWidthConstraint;
@property (strong, nonatomic) CAShapeLayer *circleLayer;

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

@property (nonatomic) BOOL isCorrectOrientation;

@property (nonatomic) AVAssetWriter *assetWriter;
@property (nonatomic) AVAssetWriterInput *assetWriterInput;

@property (nonatomic) BOOL takingStillImage;

// Utilities
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) NSTimer *videoTimer;
@property (nonatomic) NSTimer *locationTimer;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) UIImage *videoShutterImage;
@property (strong, nonatomic) UIImage *stillShutterImage;

@end

@implementation CameraViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

#pragma mark - Orientation

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureUIElements];
    
    self.createdAssetURLs = [NSMutableArray new];
    
    self.takingStillImage = NO;
    
    self.doneButtonBackground.backgroundColor = [UIColor blackColor];
    
    self.doneButtonBackground.clipsToBounds = YES;
    self.doneButtonBackground.layer.cornerRadius = 8;
    self.doneButtonImageView.clipsToBounds = YES;
    self.doneButtonImageView.layer.cornerRadius = self.doneButtonBackground.layer.cornerRadius;
    
    // Create the AVCaptureSession an set to photo
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // Prevent conflict between background music and camera
    session.automaticallyConfiguresApplicationAudioSession = NO;
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self setSession:session];

    // Setup the preview view
    [[self previewView] setSession:session];

    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // TODO: Confirm permissions
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    [self setSessionQueue:sessionQueue];

    dispatch_async(self.sessionQueue, ^{
        
        [session beginConfiguration];
        
        NSError *error = nil;

        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
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
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                
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
        
        if ([session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            //Set the session preset to photo, the default mode we enter in as
            session.sessionPreset = AVCaptureSessionPresetPhoto;
        }
        
        [session commitConfiguration];
        
        
    //End session thread
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
    
    dispatch_async([self sessionQueue], ^{
            
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

    //Restart location manager updating
    [self.locationManager startUpdatingLocation];
    
    /*
    ** Orientation notification set up
    */
    
    ///Call update block to check for orientation on load
    [self deviceOrientationDidChange:nil];

    //Set up listener for oreitnation change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:NOTIF_ORIENTATION_CHANGE object:nil];
    
    //Start tracking movement via the FRSMotionManager (acceleromotor)
    [[FRSMotionManager sharedManager] startTrackingMovement];


}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    [self.locationManager startUpdatingLocation];
    
    if(self.previewView.alpha == 0){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:.4 animations:^{
                self.previewView.alpha = 1;
            }];
                    
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_ORIENTATION_CHANGE object:nil];
    
    [self.locationManager stopUpdatingLocation];
    
    //Clear all the timers so they don't re-run
    [self.videoTimer invalidate];
    self.videoTimer = nil;
    
    [self.locationTimer invalidate];
    self.locationTimer = nil;
    
    dispatch_async([self sessionQueue], ^{
        
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
    });
    
}

-(void)configureUIElements{
    
    /* Assignment Label */
    self.assignmentLabel.alpha = 0;
    
    self.previewView.alpha = 0;

    //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
    [self.cancelButtonTapView
     addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAndReturnToPreviousTab:)]];
    
    //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
    [self.rotateImageView
     addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateRotateImageView:)]];
    
    if(!self.photoButton.selected) self.photoButton.selected = YES;
    
    [self.doneButton setTitle:@"" forState:UIControlStateNormal];
    
    self.videoShutterImage = [UIImage imageNamed:@"video-recording-icon"];
    
    self.stillShutterImage = [UIImage imageNamed:@"shutter-1"];
    
}


#pragma mark - UI Actions

- (IBAction)apertureButtonTapped:(id)sender
{
    
    //Check if we're in the correct orientation
    if (self.isCorrectOrientation == YES) {
        
        //If we're in Photo mode
        if (self.photoButton.selected) {
            
            if(!self.takingStillImage) [self snapStillImage];

        }
        //If we're in Video mode
        else {
            
            [self toggleMovieRecording];

        }
        
    }
    //Animate the rotate image to indicate the device needs to be rotated
    else{
        
        [self animateRotateImageView:nil];
    }
}


- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self cancelAndReturnToPreviousTab:YES];
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

- (IBAction)modeButtonTapped:(UIButton *)button
{
    if (!button.selected) {
        
        button.selected = YES;
        
        if (button.tag) {
            [self updateCameraMode:CameraModeVideo];
        }
        else {
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
    
    [self presentViewController:picker withScale:YES];
    
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
        [UIView animateWithDuration:.2f animations:^{
            
            [self.previewView setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            //fade out
            [UIView animateWithDuration:.2f animations:^{
                
                [self.previewView setAlpha:1.0f];
                
            } completion:nil];
            
        }];
            
    });
    
}

- (void)runVideoRecordAnimation{
    
    // Set up the shape of the circle
    int radius = 40;
    self.circleLayer = [CAShapeLayer layer];
    // Make a circular shape
    self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                       cornerRadius:radius].CGPath;
    // Center the shape in self.view
    self.circleLayer.position = CGPointMake(self.view.frame.size.width - CGRectGetMidX(self.apertureButton.frame) - radius - 3,
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

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            [self setDeviceAuthorized:NO];
        }
    }];
}

/*
** Toggles camera mode between photo/camera, * performs animation and changes preset *
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
                
                
                [self.apertureButton setImage:self.stillShutterImage forState:UIControlStateNormal];
                
                self.videoButton.selected = NO;
                
                if(!self.photoButton.selected) self.photoButton.selected = YES;
                
                [UIView animateWithDuration:.2f animations:^{
                    
                    self.previewView.alpha = 1;
                    
                }];
                    

            }];
            
        }
        else if(cameraMode == CameraModeVideo) {
            
            self.photoButton.selected = NO;
            
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
                
                [self.apertureButton setImage:self.videoShutterImage forState:UIControlStateNormal];
                self.photoButton.selected = NO;
                
                [UIView animateWithDuration:.2f animations:^{
                    self.previewView.alpha = 1;
                }];
                
            }];
            
        }
        
    });
    
}



- (void)setRecentPhotoViewHidden:(BOOL)hidden withImage:(UIImage *)image{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(hidden){
        
            [self.activityIndicator startAnimating];
            
            [UIView animateWithDuration:.5 animations:^{
                 self.doneButton.alpha = 0.0f;
                self.activityIndicator.alpha = 1.0f;
            }];
            
        }
        else{
            
            [UIView animateWithDuration:.5 animations:^{
                self.activityIndicator.alpha = 0.0f;
            } completion:^(BOOL finished) {
                
                [self.activityIndicator stopAnimating];
                [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
                self.doneButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
                
                if (image) {
                    self.doneButtonBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
                    [self.doneButtonImageView setImage:image];
                }
                
                [UIView animateWithDuration:.2 animations:^{
                     self.doneButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     self.doneButton.alpha = 1.0f;
                 } completion:^(BOOL finished) {
                      self.takingStillImage = NO;
                 }];
                
            }];
            
        }
    });
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
        
        [UIView animateWithDuration:0.5 animations:^{
            self.assignmentLabel.alpha = self.withinRangeOfDefaultAssignment ? 1.0f : 0.0f;
        } completion:^(BOOL finished) {
            if (!self.withinRangeOfDefaultAssignment) {
                self.assignmentLabel.hidden = YES;
            }
        }];
    
    }
}

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

#pragma mark - Camera Functions

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
        [self setRecentPhotoViewHidden:YES withImage:nil];
    
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
        [[AVAudioSession sharedInstance] setActive:YES
                                             error: nil];
    }
    else {
        
        [self hideUIForCameraMode:CameraModeVideo];

        //Set up timer to disable video after maximumVideoLength seconds
        self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_VIDEO_LENGTH target:self selector:@selector(videoEnded:) userInfo:nil repeats:NO];
        
        // Stops background audio
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }

    dispatch_async([self sessionQueue], ^{
        
        if (![[self movieFileOutput] isRecording]) {
            
            AVCaptureConnection *movieConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (movieConnection.active) {
            
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
                [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];

                // Turning OFF flash for video recording
                [self setTorchMode:(self.flashButton.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff)];

                NSError *writeError = nil;
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:&writeError];
                }
                
                

                [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                
            }
            
        }
        else {
            [[self movieFileOutput] stopRecording];
            [self setTorchMode:AVCaptureTorchModeOff];
        }
        
    });
}

- (void)snapStillImage
{
    self.takingStillImage = YES;
    
    dispatch_async([self sessionQueue], ^{

        [self runStillImageCaptureAnimation];
        
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer) {
                
                CFRetain(imageDataSampleBuffer);
            
                [self setRecentPhotoViewHidden:YES withImage:nil];
                
                NSMutableDictionary *metadata = [[self.location EXIFMetadata] mutableCopy];

                //Check if we have an assignment set
                if(self.defaultAssignment != nil){
                    
                    NSString *assignmentID = [NSString stringWithFormat:@"FrescoAssignmentID=%@", self.defaultAssignment.assignmentId];

                    NSDictionary *frescoDict = @{ (NSString *)kCGImagePropertyExifUserComment : assignmentID };
                    
                    [metadata setObject:frescoDict forKey:(NSString *)kCGImagePropertyExifDictionary];
                
                }

                NSInteger CGImagePropertyOrientation = 1; // AVCaptureVideoOrientationLandscapeRight
                
                [metadata setObject:@(CGImagePropertyOrientation) forKeyedSubscript:(NSString *)kCGImagePropertyOrientation];
                
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                [[[ALAssetsLibrary alloc] init] writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                    [[[ALAssetsLibrary alloc] init] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        
                        [self setRecentPhotoViewHidden:NO withImage:[UIImage imageFromAsset:asset]];
                        
                        if(assetURL != nil && [self.createdAssetURLs count] < MAX_POST_COUNT)
                            [self.createdAssetURLs addObject:assetURL];
 
                    } failureBlock:^(NSError *error) {
                        NSLog(@"Failed to produce asset");
                    }];

                }];
                
                CFRelease(imageDataSampleBuffer);
                
            }
        }];
    });
}


- (void)cancelAndReturnToPreviousTab:(BOOL)returnToPreviousTab
{
    [[FRSDataManager sharedManager] resetDraftGalleryPost];
    
    FRSTabBarController *tabBarController = ((FRSRootViewController *)self.presentingViewController).tbc;

    tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:UD_PREVIOUSLY_SELECTED_TAB];

    [self dismissViewController:self withScale:NO];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = (CGPoint){0.5, 0.5};
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
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

    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];

    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [self setRecentPhotoViewHidden:NO withImage:nil];

        if(assetURL != nil){
            [self.createdAssetURLs addObject:assetURL];
        }
        else{
            NSLog(@"%@", error);
        }

        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];

        if (backgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }
        
    }];
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

- (void)deviceOrientationDidChange:(NSNotification*)note
{
    
    if ([FRSMotionManager sharedManager].lastOrientation == UIInterfaceOrientationLandscapeRight) {
        
        self.isCorrectOrientation = YES;
        
        if (self.rotateImageView.alpha != 0.0f){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:.2f animations:^{
                    self.rotateImageView.alpha = 0.0f;
                }];
                
            });
        }

    } else {
        
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

#pragma mark - NSTimer Delegate and Selectors

- (void)videoEnded:(NSTimer *)timer{
    //End movie recording
    [self toggleMovieRecording];
}

#pragma mark - CTAssetsPickerControllerDelegate methods

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {} // required by protocol

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    return picker.selectedAssets.count < MAX_POST_COUNT;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAsset:(ALAsset *)asset
{
    
    #if TARGET_IPHONE_SIMULATOR

        return YES;
    
    #else
    
        NSString *mimeType = [asset mimeType];
    
        //Check if the asset is either a photo/video
        if (![mimeType isEqualToString:@"image/jpeg"] && ![mimeType isEqualToString:@"video/quicktime"]) {
            return NO;
        }
        
        //Check if the asset is newer than our max age
        if ([[asset valueForProperty:ALAssetPropertyDate] timeIntervalSinceDate:[NSDate date]] < MAX_ASSET_AGE) {
            return NO;
        }
    
        //Check if the asset has a location property
        if (![asset valueForProperty:ALAssetPropertyLocation]) {
            return NO;
        }

        return YES;
    
    #endif
    
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) <= MAX_VIDEO_LENGTH;
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
    
    if ((!self.currentLocation || [self.currentLocation distanceFromLocation:[locations lastObject]] > 0) && self.defaultAssignment == nil) {
    
        self.currentLocation = [locations lastObject];
        
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:20 ofLocation:self.location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
            
            if(responseObject != nil){
                
                if(![self.defaultAssignment.assignmentId isEqualToString:((FRSAssignment *)[responseObject firstObject]).assignmentId]){
                    self.defaultAssignment = [responseObject firstObject];
                }
            
                [self configureAssignmentLabel];
                
            }
            
        }];

    }
    
    //Set interval for location update every `locationUpdateInterval` seconds
    if (self.locationTimer == nil) {
        // NSLog(@"Starting timer...");
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:YES];
    }
    
    [self.locationManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // TODO: Also check for kCLAuthorizationStatusAuthorizedAlways
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:@"Access to Location Disabled"
                                     message:[NSString stringWithFormat:@"To re-enable, go to Settings and turn on Location Service for the %@ app.", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]]
                                     action:DISMISS]
                           animated:YES
                         completion:nil];

        [self.locationManager stopUpdatingLocation];
    }
}

- (void)restartLocationUpdates{
    
    if(self.defaultAssignment == nil)
        [self.locationManager startUpdatingLocation];
    else{
        [self.locationTimer invalidate];
        self.locationTimer = nil;
    }
}


@end
