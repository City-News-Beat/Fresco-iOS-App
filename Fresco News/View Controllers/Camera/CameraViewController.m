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

@property (strong, nonatomic) CAShapeLayer *circleLayer;

@property (strong, nonatomic) CLLocation* currentLocation;

/*
 ** Condition var to tell if the interval is already set
 */

@property (assign, nonatomic) BOOL intervalSet;

@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet CameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *cancelButtonTapView;
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
@property (weak, nonatomic) IBOutlet UIImageView *rotateImageView;
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
@property (nonatomic) BOOL inCorrentOrientation;

// Utilities
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) NSTimer *videoTimer;

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

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureUIElements];
    
    self.createdAssetURLs = [NSMutableArray new];
    
    // Create the AVCaptureSession an set to photo
    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    // Prevent conflict between background music and camera
    session.automaticallyConfiguresApplicationAudioSession = NO;
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self setSession:session];

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
//
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
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

    [self updateRecentPhotoView:nil];

}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    if(self.previewView.alpha == 0){
    
        [UIView animateWithDuration:.4 animations:^{
            self.previewView.alpha = 1;
        }];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

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

-(void)configureUIElements{
    
    
    /* Assignment Label */
    self.assignmentLabel.alpha = 0;

    //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
    [self.cancelButtonTapView
     addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAndReturnToPreviousTab:)]];
    
    //Adds gesture to the settings icon to segue to the ProfileSettingsViewController
    [self.rotateImageView
     addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateRotateImageView:)]];
    
    /* Orientation notificaiton set up */
    
    [self deviceOrientationDidChange:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChange:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    if(!self.photoButton.selected) self.photoButton.selected = YES;

}


#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext) {
//        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
//
//        if (isCapturingStillImage) {
//            [self runStillImageCaptureAnimation];
//        }
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

#pragma mark - UI Actions

- (IBAction)apertureButtonTapped:(id)sender
{
    if(self.inCorrentOrientation){
        
        if (self.photoButton.selected) {
            
            [self runStillImageCaptureAnimation];
            
            [self snapStillImage];

        }
        else {
            
            [self toggleMovieRecording];

        }
        
    }
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
    [UIView animateWithDuration:.8 animations:^{
        self.previewView.alpha = 0;
    }];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.title =  @"Choose Media";
    picker.autoSubmit = (sender ? NO : YES);
    picker.createdAssetURLs = self.createdAssetURLs;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UI Functions

- (void)showUIForCameraMode:(CameraMode)cameraMode
{
    
    if(cameraMode == CameraModeVideo){
        
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
            
            [self.circleLayer removeFromSuperlayer];
            
        }];
        
    }
    
    self.activityIndicator.hidden = YES;
}

- (void)hideUIForCameraMode:(CameraMode)cameraMode
{
    
    if(cameraMode == CameraModeVideo){
        
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
        
    }
    
}

- (void)runStillImageCaptureAnimation
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    //24 is the number of frames in the animation
    for (NSInteger i = 2; i < 25; i++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"shutter-%li",(long)i]]];
    }
    
    for (NSInteger i = 24; i > 0; i--) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"shutter-%li",(long)i]]];
    }
    
    [self.apertureButton.imageView setAnimationImages:[images copy]];
    
    [self.apertureButton.imageView setAnimationDuration:.2];
    
    [self.apertureButton.imageView setAnimationRepeatCount:1];
    
    [self.apertureButton.imageView startAnimating];
    
    //fade in
    [UIView animateWithDuration:.1f animations:^{
        
        [self.previewView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:.1f animations:^{
            
            [self.previewView setAlpha:1.0f];
            
        } completion:^(BOOL finished) {
            [self setRecentPhotoViewHidden:YES];
        }];
        
    }];
    
    
}

- (void)runVideoRecordAnimation{
    
    // Set up the shape of the circle
    int radius = 39;
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
        if (granted) {
            self.deviceAuthorized = YES;
        }
        else {
            self.deviceAuthorized = NO;
        }
    }];
}

/*
** Toggles camera mode between photo/camera, * performs animation and changes preset *
*/

- (void)updateCameraMode:(CameraMode)cameraMode
{
    if (cameraMode == CameraModePhoto) {
        
        [UIView animateWithDuration:.2f animations:^{
            
            self.previewView.alpha = .0f;
            self.controlsView.alpha = 1;
            
            //Reset the preview view to its original frame
            if(self.previewView.savedBounds.size.width != 0) self.previewView.frame = self.previewView.savedBounds;
            
        } completion:^(BOOL finished){
            
            //Change the preset to display properly
            [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
            [self.apertureButton setImage:[UIImage imageNamed:@"shutter-1"] forState:UIControlStateNormal];
            [self.flashButton setImage:[UIImage imageNamed:@"flash-off.png"] forState:UIControlStateNormal];
            [self.flashButton setImage:[UIImage imageNamed:@"flash-on.png"] forState:UIControlStateSelected];
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
            
            //Change the preset to display properly
            [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
            [self.apertureButton setImage:[UIImage imageNamed:@"video-recording-icon"] forState:UIControlStateNormal];
            [self.flashButton setImage:[UIImage imageNamed:@"torch-off.png"] forState:UIControlStateNormal];
            [self.flashButton setImage:[UIImage imageNamed:@"torch-on.png"] forState:UIControlStateSelected];
            self.photoButton.selected = NO;
            
            [UIView animateWithDuration:.2f animations:^{
                self.previewView.alpha = 1;
            }];
            
        }];
        
    }
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
    
    [UIView animateWithDuration:0.5 animations:^{
        self.assignmentLabel.alpha = self.withinRangeOfDefaultAssignment ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        if (!self.withinRangeOfDefaultAssignment) {
            self.assignmentLabel.hidden = YES;
        }
    }];
    
}

- (void)animateRotateImageView:(UITapGestureRecognizer *)tapGestureRecognizer{

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
}


- (void)setRecentPhotoViewHidden:(BOOL)hidden{

    if(hidden){
        
        self.doneButton.enabled = NO;
        
        self.activityIndicator.alpha = 0.0f;
        [self.activityIndicator startAnimating];
        
        [UIView animateWithDuration:.5 animations:^{
            self.doneLabel.alpha = 0.0f;
            self.activityIndicator.alpha = 1.0f;
        }];
    
    }
    else{
        
        self.doneButton.enabled = YES;
        
        [UIView animateWithDuration:.5 animations:^{
            self.doneLabel.alpha = 1.0f;
            self.activityIndicator.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.activityIndicator stopAnimating];
        }];
        
    }

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
        [self setRecentPhotoViewHidden:YES];
    
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

                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] metadata:metadata
                 completionBlock:^(NSURL *assetURL, NSError *error) {
                     [self setRecentPhotoViewHidden:NO];
                     [self updateRecentPhotoView:image];
                     [self.createdAssetURLs addObject:assetURL];
                 }];
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

    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];

    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [self setRecentPhotoViewHidden:NO];

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

- (void)deviceOrientationDidChange:(NSNotification*)note
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown || orientation == UIDeviceOrientationLandscapeRight){
    
        self.inCorrentOrientation = NO;
    
        [UIView animateWithDuration:.2f animations:^{
            self.rotateImageView.alpha = 0.7f;
        }];
        
    }
    else{
    
        self.inCorrentOrientation = YES;
        
        [UIView animateWithDuration:.2f animations:^{
            self.rotateImageView.alpha = 0.0f;
        }];
    
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
    return picker.selectedAssets.count < 10;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAsset:(ALAsset *)asset
{
    
    #if TARGET_IPHONE_SIMULATOR
        return YES;
    #else
    
        NSString *mimeType = [asset mimeType];
        
        if (![mimeType isEqualToString:@"image/jpeg"] && ![mimeType isEqualToString:@"video/quicktime"]) {
            return NO;
        }
        
        // Suspenders
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        if ([date timeIntervalSinceDate:[NSDate date]] < MAX_ASSET_AGE) {
            return NO;
        }

        if ([asset valueForProperty:ALAssetPropertyLocation]) {
            return YES;
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
    
    if (!self.currentLocation || [self.currentLocation distanceFromLocation:[locations lastObject]] > 0) {
    
        self.currentLocation = [locations lastObject];
        
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:100 ofLocation:self.location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
            
            if(responseObject != nil){
           
                self.defaultAssignment = [responseObject firstObject];
            
                [self configureAssignmentLabel];
                
            }
            
        }];

    }
    
    //Set interval for location update every `locationUpdateInterval` seconds
    if (!self.intervalSet) {
        // NSLog(@"Starting timer...");
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:YES];
        
        self.intervalSet = YES;
        
    }
    
    [self.locationManager stopUpdatingLocation];
    
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

- (void)restartLocationUpdates
{
    [self.locationManager startUpdatingLocation];
}


@end
