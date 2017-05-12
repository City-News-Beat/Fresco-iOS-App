//
//  FRSCameraViewController.m
//  Fresco
//
//  Created by Daniel Sun on 11/13/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSCameraViewController.h"

@import Photos;
@import AVFoundation;

#import "FRSAVSessionManager.h"
#import "FRSLocator.h"

#import "FRSAssignment.h"
#import "FRSCaptureModeSlider.h"
#import "FRSCameraFooterView.h"
#import "FRSCameraTracker.h"
#import "FRSCameraCapture.h"
#import "FRSTipsViewController.h"

#import "FRSTransparentAlertView.h"

#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIImage+Helpers.h"
#import "CLLocation+EXIFGPS.h"

static int const maxVideoLength = 60.0; // in seconds, triggers trim

@interface FRSCameraViewController () <AVCaptureFileOutputRecordingDelegate, FRSCaptureModeSliderDelegate, FRSCameraFooterViewDelegate, FRSCameraCaptureDelegate, FRSAlertViewDelegate>

@property (strong, nonatomic) FRSAVSessionManager *sessionManager;

@property (strong, nonatomic) UIView *preview;

@property (strong, nonatomic) FRSCameraFooterView *footerView;

@property (strong, nonatomic) UIImageView *videoRotateIV;

@property (strong, nonatomic) UIView *apertureShadowView;
@property (strong, nonatomic) UIView *apertureAnimationView;
@property (strong, nonatomic) UIView *apertureBackground;
@property (strong, nonatomic) UIImageView *apertureImageView;
@property (strong, nonatomic) UIView *apertureMask;
@property (strong, nonatomic) UIView *ivContainer;
@property (strong, nonatomic) UIButton *clearButton;

@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIButton *apertureButton;

@property (strong, nonatomic) UIImageView *previewBackgroundIV;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *closeButton;

@property (nonatomic) BOOL capturingImage;

@property (nonatomic) BOOL flashIsOn;
@property (nonatomic) BOOL torchIsOn;

@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property (strong, nonatomic) NSTimer *videoTimer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic) CGRect originalApertureFrame;

@property (strong, nonatomic) FRSCaptureModeSlider *captureModeSlider;
@property (strong, nonatomic) FRSCameraTracker *cameraTracker;

@property (strong, nonatomic) FRSTransparentAlertView *tipsAlert;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftGestureRec;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRightGestureRec;

@property (strong, nonatomic) FRSAlertView *rotateDeviceAlert;

@property (nonatomic) BOOL firstRun;

@end

@implementation FRSCameraViewController

- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode {
    self = [super init];

    if (self) {
        [self setupDefaultWithCaptureMode:captureMode];
    }
    return self;
}

- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode selectedAssignment:(NSDictionary *)assignment selectedGlobalAssignment:(NSDictionary *)globalAssignment {
    self = [super init];

    if (self) {
        [self setupDefaultWithCaptureMode:captureMode];
        self.preselectedGlobalAssignment = globalAssignment;
        self.preselectedAssignment = assignment;
    }
    return self;
}

- (void)setupDefaultWithCaptureMode:(FRSCaptureMode)captureMode {
    self.sessionManager = [FRSAVSessionManager defaultManager];
    self.captureMode = captureMode;
    self.lastOrientation = UIDeviceOrientationPortrait;
    self.isRecording = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureUI];
    [self setAppropriateIconsForCaptureState];
    [self adjustFramesForCaptureState];
    [self rotateAppForOrientation:self.lastOrientation];
    [self checkLibrary];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoCaptureIfNeeded) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [FRSTracker screen:@"Camera"];


    if (!self.sessionManager.session.isRunning) {
        [self.sessionManager startCaptureSessionForCaptureMode:self.captureMode
                                                withCompletion:^{
                                                  [self configurePreviewLayer];
                                                }];
    }

    [self shouldShowStatusBar:NO animated:YES];
    [self.navigationController setNavigationBarHidden:TRUE animated:YES];
    
    self.cameraTracker = [[FRSCameraTracker alloc] init];
    self.cameraTracker.sessionManager = self.sessionManager;
    self.cameraTracker.parentController = self;
    [self.cameraTracker startTrackingMovement];
    
    if (!self.apertureButton) {
        [self configureApertureButton];
        [self rotateAppForOrientation:self.lastOrientation];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    entry = [NSDate date];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.sessionManager.movieFileOutput.isRecording) {
        [self toggleVideoRecording];
    }
    
    [self.sessionManager clearCaptureSession];
    [_captureVideoPreviewLayer removeFromSuperlayer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (entry) {
        exit = [NSDate date];
        NSInteger secondsInCamera = [exit timeIntervalSinceDate:entry];
        [FRSTracker track:cameraSession parameters:@{ activityDuration : @(secondsInCamera) }];
    }

    [self.cameraTracker stopTrackingMovement];

    [self shouldShowStatusBar:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch Assets

- (void)checkLibrary {
    [self fetchGalleryAssetsInBackgroundWithCompletion:Nil];
}

- (void)fetchGalleryAssetsInBackgroundWithCompletion:(void (^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.fileLoader = [[FRSFileLoader alloc] initWithDelegate:Nil];
        PHAsset *firstAsset = [self.fileLoader assetAtIndex:0];
        
        if (firstAsset) {
            // image that fits predicate at index 0
            [self.fileLoader getDataFromAsset:firstAsset
                                     callback:^(UIImage *image, AVAsset *video, PHAssetMediaType mediaType, NSError *error) {
                                         [self.footerView updatePreviewButtonWithImage:image];
                                         self.capturingImage = NO;
                                     }];
        } else {
            // no image
        }
    });
}

#pragma mark - UI configuration methods

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.firstRun = YES;
    [self configurePreview];
    [self configureGestureRecognizer];
    [self configureBottomContainer];
    [self configureTopContainer];
}

- (void)configureTopContainer {

    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 24)];
    self.topContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topContainer];

    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, -7, 38, 38)];
    [self.closeButton setImage:[UIImage imageNamed:@"x-icon-light"] forState:UIControlStateNormal];
    [self.closeButton addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];

    [self.closeButton addTarget:self action:@selector(dismissAndReturnToPreviousTab) forControlEvents:UIControlEventTouchUpInside];
    [self.topContainer addSubview:self.closeButton];
}

- (void)configureGestureRecognizer {
    self.swipeLeftGestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    self.swipeLeftGestureRec.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:self.swipeLeftGestureRec];
    
    self.swipeRightGestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    self.swipeRightGestureRec.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.swipeRightGestureRec];
}

-(void)swipeLeft {
    [self.footerView.captureModeSlider swipeLeft];
}

-(void)swipeRight {
    [self.footerView.captureModeSlider swipeRight];
}

#pragma mark - FRSCaptureModeDelegate
- (void)captureModeDidUpdate:(FRSCaptureMode)captureMode {

    if (captureMode == FRSCaptureModePhoto) {
        [self toggleCaptureModeToPhoto:YES];
    } else {
        [self toggleCaptureModeToPhoto:NO];
    }
}

- (void)configurePreview {
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * PHOTO_FRAME_RATIO)];
    self.preview.backgroundColor = [UIColor blackColor];

    UITapGestureRecognizer *focusGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
    [self.preview addGestureRecognizer:focusGR];

    [self.view addSubview:self.preview];
}


- (void)configurePreviewLayer {
    dispatch_async(dispatch_get_main_queue(), ^{
      CALayer *viewLayer = self.preview.layer;
      self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.session];
      self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
      self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
      [viewLayer addSublayer:self.captureVideoPreviewLayer];
      self.captureVideoPreviewLayer.frame = self.preview.frame;
    });
}


- (void)configureBottomContainer {
    self.footerView = [[FRSCameraFooterView alloc] initWithDelegate:self];
    [self.view addSubview:self.footerView];
}



#pragma mark - FRSFooterViewDelegate

- (void)didTapNextButton {
    FRSFileViewController *fileView = [[FRSFileViewController alloc] init];
    fileView.preselectedGlobalAssignment = self.preselectedGlobalAssignment;
    fileView.preselectedAssignment = self.preselectedAssignment;

    [self.navigationController pushViewController:fileView animated:YES];
}

- (void)didTapTipsButton {
    self.tipsAlert = [[FRSTransparentAlertView alloc] initWithCaptureMode:self.footerView.captureModeSlider.currentIndex tipIndex:1 delegate:self];
    [self.tipsAlert show];
}

- (void)segueToTipsAction {
    FRSTipsViewController *tipsViewController = [[FRSTipsViewController alloc] init];
    [self.navigationController pushViewController:tipsViewController animated:YES];
}

// TODO: move aperture button out
- (void)configureApertureButton {
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        self.apertureShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
        [self.apertureShadowView centerHorizontallyInView:self.footerView];
        [self.apertureShadowView centerVerticallyInView:self.footerView];
        [self.apertureShadowView addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
        [self.footerView addSubview:self.apertureShadowView];
        
        self.apertureBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
        self.apertureBackground.layer.cornerRadius = self.apertureBackground.frame.size.width / 2.;
        self.apertureBackground.layer.masksToBounds = YES;
        [self.apertureShadowView addSubview:self.apertureBackground];
        
        self.apertureBackground.backgroundColor = [UIColor blueColor];
        
        self.apertureAnimationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
        [self.apertureAnimationView centerHorizontallyInView:self.apertureBackground];
        [self.apertureAnimationView centerVerticallyInView:self.apertureBackground];
        self.apertureAnimationView.layer.cornerRadius = APERTURE_WIDTH / 2.;
        self.apertureAnimationView.layer.masksToBounds = YES;
        self.apertureAnimationView.alpha = 0.0;
        self.apertureAnimationView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.apertureBackground addSubview:self.apertureAnimationView];
        
        self.apertureMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.apertureBackground.frame.size.width, self.apertureBackground.frame.size.height)];
        self.apertureMask.backgroundColor = [UIColor clearColor];
        self.apertureMask.layer.borderColor = [UIColor frescoOrangeColor].CGColor;
        self.apertureMask.layer.borderWidth = 4.0;
        [self.apertureBackground addSubview:self.apertureMask];
        self.apertureMask.layer.cornerRadius = self.apertureMask.frame.size.width / 2;
        
        self.originalApertureFrame = CGRectMake(4, 4, APERTURE_WIDTH - 8, APERTURE_WIDTH - 8);
        self.apertureButton = [[UIButton alloc] initWithFrame:self.originalApertureFrame];
        
        self.apertureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH - 8, APERTURE_WIDTH - 8)];
        [self.apertureImageView setImage:[UIImage imageNamed:@"camera-iris"]];
        self.apertureImageView.alpha = 1;
        self.apertureImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.ivContainer = [[UIView alloc] initWithFrame:self.apertureShadowView.frame];
        
        self.videoRotateIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
        [self.videoRotateIV centerHorizontallyInView:self.ivContainer];
        [self.videoRotateIV centerVerticallyInView:self.ivContainer];
        
        [self.videoRotateIV setImage:[UIImage imageNamed:@"rotate"]];
        self.videoRotateIV.layer.shadowColor = [UIColor blackColor].CGColor;
        self.videoRotateIV.layer.shadowOffset = CGSizeMake(0, 2);
        self.videoRotateIV.layer.shadowOpacity = 0.15;
        self.videoRotateIV.layer.shadowRadius = 1.0;
        self.videoRotateIV.alpha = 1.0;
        self.videoRotateIV.userInteractionEnabled = YES;
        
        [self.apertureButton addSubview:self.apertureImageView];
        
        [self.ivContainer addSubview:self.videoRotateIV];
        
        [self.apertureMask addSubview:self.apertureButton];
        
        [self.footerView addSubview:self.ivContainer];
        
        self.clearButton = [[UIButton alloc] initWithFrame:self.ivContainer.bounds];
        [self.ivContainer addSubview:self.clearButton];
        
        [self.apertureButton addTarget:self action:@selector(handleApertureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.clearButton addTarget:self action:@selector(handleApertureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    });
}


- (void)animateRotateView:(UIView *)view withDuration:(CGFloat)duration counterClockwise:(BOOL)counterClockwise {

    NSInteger mult = 1;
    if (counterClockwise)
        mult = -1;

    [UIView animateWithDuration:duration / 3.
        delay:0
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
          view.transform = CGAffineTransformMakeRotation((M_PI * 2.) / 3. * mult);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:duration / 3.
              delay:0
              options:UIViewAnimationOptionCurveLinear
              animations:^{
                view.transform = CGAffineTransformMakeRotation((M_PI * 2.) * 2. / 3. * mult);
              }
              completion:^(BOOL finished) {
                [UIView animateWithDuration:duration / 3.
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                   view.transform = CGAffineTransformMakeRotation(M_PI * 2. * mult);
                                 }
                                 completion:nil];
              }];
        }];
}

- (void)animateVideoRotateHide {

    [UIView animateWithDuration:0.45 / 2
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{

          self.apertureShadowView.transform = CGAffineTransformMakeScale(0.9, 0.9);

        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.45 / 2
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             self.apertureShadowView.transform = CGAffineTransformMakeScale(1, 1);
                           }
                           completion:nil];
        }];

    [self animateRotateView:self.videoRotateIV withDuration:0.45 counterClockwise:YES];

    [UIView animateWithDuration:0.45
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.ivContainer.transform = CGAffineTransformMakeScale(0.01, 0.01);
                       self.videoRotateIV.alpha = 0;

                     }
                     completion:nil];

    [UIView animateWithDuration:0.45
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.apertureImageView.transform = CGAffineTransformMakeRotation(M_PI);
                       self.apertureImageView.transform = CGAffineTransformMakeScale(1, 1);
                       self.apertureImageView.alpha = 1;

                     }
                     completion:nil];
}

- (void)animateVideoRotationAppear {

    CGFloat duration = self.firstRun ? 0.0 : 0.45;

    [UIView animateWithDuration:duration / 2
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{

          self.apertureShadowView.transform = CGAffineTransformMakeScale(0.9, 0.9);

        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:duration / 2
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             self.apertureShadowView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                           }
                           completion:nil];
        }];

    [self animateRotateView:self.videoRotateIV withDuration:duration counterClockwise:NO];

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.videoRotateIV.alpha = 1.0;

                       self.ivContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);

                     }
                     completion:^(BOOL finished){
                         self.firstRun = NO;
                     }];

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.apertureImageView.transform = CGAffineTransformMakeRotation(M_PI);
                       self.apertureImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                       self.apertureImageView.alpha = 0;

                     }
                     completion:nil];
}

- (void)setAppropriateIconsForCaptureState {
    if (self.captureMode == FRSCaptureModePhoto) {
        [self animateShutterExpansionWithColor:[UIColor frescoOrangeColor]];
    } else {
        [self animateShutterExpansionWithColor:[UIColor frescoRedColor]];
    }
}


#pragma mark - Animation
- (void)animateShutterExpansionWithColor:(UIColor *)color {

    self.apertureAnimationView.backgroundColor = color;
    self.apertureAnimationView.alpha = 1.0;

    [UIView animateWithDuration:0.3
        delay:0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.apertureAnimationView.transform = CGAffineTransformMakeScale(1.00, 1.00);

        }
        completion:^(BOOL finished) {
          self.apertureAnimationView.alpha = 0.0;
          self.apertureAnimationView.transform = CGAffineTransformMakeScale(0.1, 0.1);
          self.apertureAnimationView.center = self.apertureBackground.center;
          self.apertureBackground.backgroundColor = color;
          self.apertureMask.layer.borderColor = color.CGColor;
        }];
}

- (void)adjustFramesForCaptureState {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect bigPreviewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        CGRect smallPreviewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * PHOTO_FRAME_RATIO);
        
        self.preview.frame = bigPreviewFrame;
        self.captureVideoPreviewLayer.frame = bigPreviewFrame;
        
        if (self.captureMode == FRSCaptureModePhoto) {
            self.preview.frame = smallPreviewFrame;
            self.captureVideoPreviewLayer.frame = smallPreviewFrame;
        } else {
            self.preview.frame = bigPreviewFrame;
            self.captureVideoPreviewLayer.frame = bigPreviewFrame;
        }
    });
}

// TODO: Move out all orientation
- (void)rotateAppForOrientation:(UIDeviceOrientation)o {
    
    if (self.isRecording) {
        return;
    }
    
    if (self.rotateDeviceAlert) {
        [self.rotateDeviceAlert dismiss];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat angle = 0;

        if (o == UIDeviceOrientationLandscapeLeft) {
            
            if (self.captureMode == FRSCaptureModeVideo) {
                [self animateVideoRotateHide];
                self.videoRotateIV.alpha = 0.0;
            }
            
            angle = M_PI_2;
            
        } else if (o == UIDeviceOrientationLandscapeRight) {
            
            if (self.captureMode == FRSCaptureModeVideo) {
                
                [self animateVideoRotateHide];
                self.videoRotateIV.alpha = 0.0;
            }
            
            angle = -M_PI_2;
            
        } else if (o == UIDeviceOrientationPortrait) {
            
            if (self.captureMode == FRSCaptureModeVideo) {
                [self animateVideoRotationAppear];
                self.videoRotateIV.alpha = 1.0;
            }
            
            [UIView animateWithDuration:0.1
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.topContainer.alpha = 0;
                                 self.topContainer.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, 0), angle);
                             }
                             completion:^(BOOL finished) {
                                 self.topContainer.alpha = 1;
                             }];
            
        } else {
            return;
        }
        
        [UIView beginAnimations:@"rotation" context:nil];
        [UIView setAnimationDuration:0.2];
        
        CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
        self.flashButton.transform = rotation;
        self.apertureBackground.transform = rotation;
        self.previewBackgroundIV.transform = rotation;
        self.footerView.tipsButton.transform = rotation;
        self.footerView.nextButtonContainer.transform = rotation;
        self.footerView.flashButton.transform = rotation;
//        self.tipsAlert.transform = rotation;
        [UIView commitAnimations];
    });
}

- (void)animateShutterWithCompletion:(void (^)())completion {

    dispatch_async(dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.15
                            delay:0.0
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         self.apertureButton.transform = CGAffineTransformMakeRotation(M_PI / -2);
                       }
                       completion:nil];

      [UIView animateWithDuration:0.15
          delay:0
          options:UIViewAnimationOptionCurveEaseInOut
          animations:^{
            self.apertureButton.transform = CGAffineTransformMakeScale(4.00, 4.00);
          }
          completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15
                delay:0.06
                options:UIViewAnimationOptionCurveEaseOut
                animations:^{
                  self.apertureButton.transform = CGAffineTransformMakeScale(1.00, 1.00);
                }
                completion:^(BOOL finished) {
                  self.apertureButton.frame = self.originalApertureFrame;
                }];
          }];
    });
}

#pragma mark - Button action handlers

- (void)handleApertureButtonTapped:(UIButton *)button {

    if (self.captureMode == FRSCaptureModePhoto) {
        [self captureStillImage];
    } else {
        if (self.lastOrientation == UIDeviceOrientationPortrait) {
            [self presentRotateAlert];
        } else {
            [self toggleVideoRecording];
        }
    }
}

- (void)presentRotateAlert {
    if (!self.rotateDeviceAlert) {
        self.rotateDeviceAlert = [[FRSAlertView alloc] initWithTitle:@"ROTATE YOUR PHONE!" message:@"Videos look way better on the big screen when they're in landscape! Tilt your device left or right to start shooting a video." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
    }
    [self.rotateDeviceAlert show];
}


// TODO: clean up this implementation.
- (void)toggleCaptureModeToPhoto:(BOOL)displayPhoto {

    /* Disables torch when returning from video toggle and torch is enabled */
    [self.footerView torch:NO];

    /* Disable mask for transition animation */
    self.apertureMask.layer.borderColor = [UIColor clearColor].CGColor;

    if (!displayPhoto) {
        
        if (self.captureMode == FRSCaptureModeVideo) {
            return;
        }
        
        self.captureMode = FRSCaptureModeVideo;
        self.apertureImageView.alpha = 1;

        [self.sessionManager.session beginConfiguration];

        if ([self.sessionManager.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self.sessionManager.session setSessionPreset:AVCaptureSessionPresetHigh];
            });
        }

        [self.sessionManager.session commitConfiguration];

    } else {
        self.captureMode = FRSCaptureModePhoto;

        [self animateVideoRotateHide];

        [self.sessionManager.session beginConfiguration];

        if ([self.sessionManager.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self.sessionManager.session setSessionPreset:AVCaptureSessionPresetPhoto];
            });
        }

        [self.sessionManager.session commitConfiguration];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rotateAppForOrientation:self.lastOrientation];
        [self setAppropriateIconsForCaptureState];
        [self adjustFramesForCaptureState];
    });
    
}

- (UIImage *)snapShot {
    UIGraphicsBeginImageContextWithOptions(self.captureVideoPreviewLayer.frame.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.captureVideoPreviewLayer.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Camera focus

- (void)handleTapToFocus:(UITapGestureRecognizer *)gr {
    CGPoint devicePoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:[gr locationInView:gr.view]];

    CGPoint rawPoint = [gr locationInView:gr.view];
    [self playFocusAnimationAtPoint:rawPoint];

    [self.sessionManager focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)playFocusAnimationAtPoint:(CGPoint)devicePoint {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    circle.backgroundColor = [UIColor clearColor];
    circle.layer.borderColor = [UIColor whiteColor].CGColor;
    circle.layer.borderWidth = 2.0;
    circle.alpha = 0.0;
    circle.center = devicePoint;
    circle.layer.cornerRadius = circle.frame.size.height / 2;
    circle.clipsToBounds = YES;

    [self.preview addSubview:circle];

    [UIView animateWithDuration:0.3
        delay:0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          circle.alpha = 1.0;
          circle.transform = CGAffineTransformMakeScale(0.6, 0.6);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.3
              delay:0.0
              options:UIViewAnimationOptionCurveEaseInOut
              animations:^{
                circle.alpha = 0;
              }
              completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [circle removeFromSuperview];
                });
              }];
        }];
}


- (void)didCaptureStillImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateShutterWithCompletion:nil];
    });
}



// TODO: Move all this out
#pragma mark - Capture data processing

- (void)captureStillImage {
    FRSCameraCapture *cameraCapture = [[FRSCameraCapture alloc] initWithDelegate:self];
    [cameraCapture captureStillImageWithSessionManager:self.sessionManager completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            [self.footerView updatePreviewButtonWithImage:[UIImage imageWithData:responseObject scale:.1]];
        }
    }];
}

- (void)stopVideoCaptureIfNeeded {
    if (!self.sessionManager.movieFileOutput.isRecording)
        return;
    [self toggleVideoRecording];
}


- (void)toggleVideoRecording {

    if (self.sessionManager.movieFileOutput.isRecording) {

        //Clear the timer so it doesn't re-run
        [self.videoTimer invalidate];
        self.videoTimer = nil;

        [self stopRecordingAnimation];
        self.previewBackgroundIV.alpha = 1.0;
        [self animateCloseButtonHide:NO];
    } else {
        self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:maxVideoLength target:self selector:@selector(videoEnded:) userInfo:nil repeats:NO];
        [self animateCloseButtonHide:YES];
    }

    dispatch_async(self.sessionManager.sessionQueue, ^{

      if (!self.sessionManager.movieFileOutput.isRecording) {
          self.isRecording = TRUE;
          
          self.swipeRightGestureRec.enabled = NO;
          self.swipeLeftGestureRec.enabled = NO;

          AVCaptureConnection *movieConnection = [self.sessionManager.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];

          if (!movieConnection) {
              [self.sessionManager.session beginConfiguration];

              if ([self.sessionManager.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
                  //Set the session preset to photo, the default mode we enter in as
                  [self.sessionManager.session setSessionPreset:AVCaptureSessionPresetHigh];
              }

              [self.sessionManager.session commitConfiguration];
          }

          movieConnection = [self.sessionManager.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];

          if (movieConnection.active) {

              AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
              item.keySpace = AVMetadataKeySpaceCommon;
              item.key = AVMetadataCommonKeyLocation;
              item.value = [NSString
                            stringWithFormat:@"%+08.4lf%+09.4lf/",
                            [FRSLocator sharedLocator].currentLocation.coordinate.latitude,
                            [FRSLocator sharedLocator].currentLocation.coordinate.longitude];
              
              AVMutableMetadataItem *captureType = [[AVMutableMetadataItem alloc] init];
              NSString *captureTypeString = @"";

              switch (self.footerView.captureModeSlider.currentIndex) {
                  case FRSCaptureModeVideo:
                      captureTypeString = @"video";
                      break;
                  case FRSCaptureModeWide:
                      captureTypeString = @"wide";
                      break;
                  case FRSCaptureModeInterview:
                      captureTypeString = @"interview";
                      break;
                  case FRSCaptureModePan:
                      captureTypeString = @"pan";
                      break;
                      
                  default:
                      break;
              }
              
              captureType.keySpace = AVMetadataKeySpaceCommon;
              captureType.key = @"capture_type";
              captureType.value = captureTypeString;
              
              self.sessionManager.movieFileOutput.metadata = @[ item , captureType ];

              if ([UIDevice currentDevice].isMultitaskingSupported) {
                  // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                  // callback is not received until AVCam returns to the foreground unless you request background execution time.
                  // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                  // To conclude this background execution, -endBackgroundTask is called in
                  // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                  self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
              }

              // Update the orientation on the movie file output video connection before starting recording.
              AVCaptureConnection *connection = [self.sessionManager.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
              connection.videoOrientation = [self orientationFromDeviceOrientaton];

              // Start recording to a temporary file.
              NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
              NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
              [self.sessionManager.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
              //                [self.sessionManager.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
              dispatch_async(dispatch_get_main_queue(), ^{
                [self runVideoRecordAnimation];
              });
          }

      } else {
          self.swipeRightGestureRec.enabled = YES;
          self.swipeLeftGestureRec.enabled = YES;
          [self.sessionManager.movieFileOutput stopRecording];
      }
    });
}

- (void)videoEnded:(NSTimer *)timer {
    [self toggleVideoRecording];
}

#pragma mark - File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;

    dispatch_block_t cleanup = ^{
      [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
      if (currentBackgroundRecordingID != UIBackgroundTaskInvalid) {
          [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
      }
    };
    self.isRecording = FALSE;
    BOOL success = YES;

    if (error) {
        NSLog(@"Movie file finishing error: %@", error);
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if (success) {
        // Check authorization status.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
          if (status == PHAuthorizationStatusAuthorized) {
              // Save the movie file to the photo library and cleanup.
              [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                // In iOS 9 and later, it's possible to move the file into the photo library without duplicating the file data.
                // This avoids using double the disk space during save, which can make a difference on devices with limited free disk space.
                if ([PHAssetResourceCreationOptions class]) {
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    options.shouldMoveFile = YES;
                    PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                } else {
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                }
              }
                  completionHandler:^(BOOL success, NSError *error) {
                    if (!success) {
                        NSLog(@"Could not save movie to photo library: %@", error);
                    } else {
                        // This dispatch_after is a hotfix. Without it the next button does not update.
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self fetchGalleryAssetsInBackgroundWithCompletion:nil];
                        });
                    }
                  }];
          } else {
              cleanup();
          }
        }];
    } else {
        cleanup();
    }
}

- (void)runVideoRecordAnimation {
    
    [self.footerView hide];

    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.apertureButton.transform = CGAffineTransformMakeRotation(M_PI / -2);
                     }
                     completion:nil];

    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.apertureButton.transform = CGAffineTransformMakeScale(4.00, 4.00);
                     }
                     completion:nil];

    self.previewBackgroundIV.alpha = 0.0;

    int radius = 30;
    self.circleLayer = [CAShapeLayer layer];
    // Make a circular shape

    self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0 * radius, 2.0 * radius)
                                                       cornerRadius:radius]
                                .CGPath;

    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.apertureBackground.frame) - 30, 6);

    // Configure the apperence of the circle
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleLayer.lineWidth = 4;

    // Add to parent layer
    [self.apertureBackground.layer addSublayer:self.circleLayer];

    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration = maxVideoLength; // for testing purposes
    drawAnimation.repeatCount = 1.0; // Animate only once..

    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue = [NSNumber numberWithFloat:1.0f];

    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    // Add the animation to the circle
    [self.circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

- (void)stopRecordingAnimation {
    
    [self.footerView show];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.circleLayer.opacity = 0;
                             
                             self.apertureButton.alpha = 1;
                             self.apertureButton.transform = CGAffineTransformMakeScale(1.000, 1.000);
                             
                         }
                         completion:^(BOOL finished) {
                             [self.circleLayer removeFromSuperlayer];
                             
                         }];
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.apertureButton.transform = CGAffineTransformMakeRotation(M_PI);
                             
                         }
                         completion:nil];
    });
}

- (void)animateCloseButtonHide:(BOOL)shouldHide {
    
    if (shouldHide) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.closeButton.alpha = 0;
                             
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.closeButton.alpha = 1;
                             
                         }
                         completion:nil];
    }
}


#pragma mark - Navigation

- (void)dismissAndReturnToPreviousTab {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self shouldShowStatusBar:YES animated:YES];
}

#pragma mark - Orientation

- (AVCaptureVideoOrientation)orientationFromDeviceOrientaton {
    switch (self.lastOrientation) {
    case UIDeviceOrientationLandscapeLeft:
        return AVCaptureVideoOrientationLandscapeRight;
        break;
    case UIDeviceOrientationLandscapeRight:
        return AVCaptureVideoOrientationLandscapeLeft;
        break;
    case UIDeviceOrientationPortrait:
        return AVCaptureVideoOrientationPortrait;
    default:
        return AVCaptureVideoOrientationPortrait;
    }
}


@end
