//
//  FRSCameraViewController.m
//  Fresco
//
//  Created by Daniel Sun on 11/13/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSCameraViewController.h"


#import "BaseNavigationController.h"
#import "AssetsPickerController.h"

//Apple APIs
@import Photos;
@import AVFoundation;

//Views


//Managers
#import "FRSLocationManager.h"
#import "FRSDataManager.h"
#import "FRSGalleryAssetsManager.h"
#import "FRSAVSessionManager.h"

//Categories
#import "UIColor+Additions.h"
#import "UIView+Helpers.h"
#import "UIImage+Helpers.h"

//Models
#import "FRSAssignment.h"
#import "CLLocation+EXIFGPS.h"

#import "FRSRootViewController.h"
#import "FRSUploadManager.h"
#import "FRSTabBarController.h"


//Root View Controller
#import "FRSRootViewController.h"



#define ICON_WIDTH 24
#define PREVIEW_WIDTH 56
#define APERTURE_WIDTH 72
#define SIDE_PAD 12
#define PHOTO_FRAME_RATIO 4/3



@interface FRSCameraViewController () <CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) FRSAVSessionManager *sessionManager;
@property (strong, nonatomic) FRSLocationManager *locationManager;
@property (strong, nonatomic) FRSGalleryAssetsManager *assetsManager;

@property (strong, nonatomic) UIView *preview;

@property (strong, nonatomic) UIView *bottomClearContainer;
@property (strong, nonatomic) UIView *bottomOpaqueContainer;


@property (strong, nonatomic) UIView *apertureShadowView;
@property (strong, nonatomic) UIView *apertureAnimationView;
@property (strong, nonatomic) UIView *apertureBackground;
@property (strong, nonatomic) UIImageView *apertureImageView;
@property (strong, nonatomic) UIView *apertureMask;

@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIButton *apertureButton;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIImageView *previewBackgroundIV;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (strong, nonatomic) UIView *captureModeToggleView;
@property (strong, nonatomic) UIImageView *cameraIV;
@property (strong, nonatomic) UIImageView *videoIV;

@property (strong, nonatomic) UIButton *flashButton;

@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) UIImageView *locationIV;
@property (strong, nonatomic) UILabel *assignmentLabel;

@property (strong, nonatomic) UIView *whiteView;


@property (nonatomic) UIDeviceOrientation currentOrientation;

@property (nonatomic) BOOL capturingImage;

@property (nonatomic) BOOL flashIsOn;
@property (nonatomic) BOOL torchIsOn;

@property (nonatomic, strong) FRSTabBarController *tabBarController;

@property (strong, nonatomic) CAShapeLayer *circleLayer;

@property (nonatomic) BOOL isRecording;

@property (strong, nonatomic) NSTimer *videoTimer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic) BOOL firstTime;

@property (nonatomic) CGRect originalApertureFrame;

@end

@implementation FRSCameraViewController

//-(instancetype)init{
//    self = [super init];
//    if (self){
//        self.sessionManager = [FRSAVSessionManager defaultManager];
//        self.locationManager = [FRSLocationManager sharedManager];
//        self.assetsManager = [FRSGalleryAssetsManager sharedManager];
//        self.currentOrientation = [UIDevice currentDevice].orientation;
//
//
//        self.firstTime = YES;
//
//    }
//    return self;
//}

-(instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode{
    self = [super init];
    if (self){
        self.sessionManager = [FRSAVSessionManager defaultManager];
        self.locationManager = [FRSLocationManager sharedManager];
        self.assetsManager = [FRSGalleryAssetsManager sharedManager];
        self.currentOrientation = [UIDevice currentDevice].orientation;
        self.captureMode = captureMode;
        self.firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    [self configureUI];
    
    [self setAppropriateIconsForCaptureState];
    [self adjustFramesForCaptureState];
    
    [self addObservers];
    
    [[FRSGalleryAssetsManager sharedManager] fetchGalleryAssetsInBackgroundWithCompletion:^{
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                status == PHAuthorizationStatusAuthorized ? [self updatePreviewButtonWithAsset] : [self updatePreviewButtonWithImage:[UIImage imageNamed:@"camera-roll"]];
            });
        }];
    }];
    
    
    self.isRecording = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //hide status bar before view is loaded.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.isPresented = YES;
    
    if (!self.sessionManager.session.isRunning){
        
        [self.sessionManager startCaptureSessionForCaptureMode:self.captureMode withCompletion:^{
            [self configurePreviewLayer];
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    

    [super viewDidAppear:animated];
    [self fadeInPreview];
    
    [self.locationManager setupLocationMonitoringForState:LocationManagerStateForeground];
    self.locationManager.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.locationManager stopLocationUpdates];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    [self.sessionManager clearCaptureSession];
    
    [_captureVideoPreviewLayer removeFromSuperlayer];
    
    self.isPresented = NO;
}


-(void)fadeInPreview{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //        [UIView animateWithDuration:0.2 animations:^{
        self.preview.alpha = 1.0;
        //        }];
        
    });
}


#pragma mark - UI configuration methods

-(void)configureUI{
    [self configurePreview];
    [self configureBottomContainer];
    [self configureTopContainer];
}

-(void)configureTopContainer{
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 24)];
    self.topContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topContainer];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, -7, 38, 38)];
    [self.closeButton setImage:[UIImage imageNamed:@"x-icon-light"] forState:UIControlStateNormal];
    [self.closeButton addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    
    [self.closeButton addTarget:self action:@selector(dismissAndReturnToPreviousTab) forControlEvents:UIControlEventTouchUpInside];
    [self.topContainer addSubview:self.closeButton];
    
    self.locationIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.closeButton.frame.origin.x + self.closeButton.frame.size.width + 17, 1, 22, 22)];
    self.locationIV.contentMode = UIViewContentModeScaleAspectFit;
    self.locationIV.image = [UIImage imageNamed:@"crosshairs-icon"];
    [self.locationIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    self.locationIV.alpha = 0.0;
    [self.topContainer addSubview:self.locationIV];
    
    self.assignmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12 + 24 + 17 + 22 + 7, 0, [self assignmentLabelWidth], 24)];
    self.assignmentLabel.textColor = [UIColor whiteColor];
    //    self.assignmentLabel.font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:15];
    self.assignmentLabel.font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:15];
    [self.assignmentLabel addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    self.assignmentLabel.alpha = 0.0;
    [self.topContainer addSubview:self.assignmentLabel];
    
}

-(NSInteger)assignmentLabelWidth{
    return [UIScreen mainScreen].bounds.size.width - 24 - 22 - 10 - 17 - 7 - 12;
}

-(void)configurePreview{
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * PHOTO_FRAME_RATIO)];
    self.preview.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *focusGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
    [self.preview addGestureRecognizer:focusGR];
    
    [self.view addSubview:self.preview];
}

-(void)configurePreviewLayer{
    dispatch_async(dispatch_get_main_queue(), ^{
        CALayer *viewLayer = self.preview.layer;
        self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.session];
        self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [viewLayer addSublayer:self.captureVideoPreviewLayer];
        self.captureVideoPreviewLayer.frame = self.preview.frame;
    });
}

-(void)updatePreviewButtonWithAsset{
    PHAsset *asset = [self.assetsManager.fetchResult firstObject];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.previewButton.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result){
            self.previewBackgroundIV.alpha = 0;
        }
        else {
            self.previewBackgroundIV.alpha = 1.0;
            
            if (self.firstTime){ //This is the first time the preview button is being created
                [self.previewButton setImage:result forState:UIControlStateNormal];
                self.firstTime = NO;
            }
        }
    }];
}

- (void)dismissAndReturnToPreviousTab
{
    [[FRSUploadManager sharedManager] resetDraftGalleryPost];
    
    FRSTabBarController *tabBarController = ((FRSRootViewController *)self.presentingViewController).tbc;
    
    tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:UD_PREVIOUSLY_SELECTED_TAB];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updatePreviewButtonWithImage:(UIImage *)image{
    
    [self.assetsManager fetchGalleryAssetsInBackgroundWithCompletion:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *temp = [[UIImageView alloc] initWithFrame:self.previewButton.frame];
        temp.image = image;
        [temp clipAsCircle];
        temp.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
        
        if (self.previewBackgroundIV.alpha <= 0){
            [self.previewBackgroundIV addSubview:temp];
            
            [self createNextButtonWithFrame:self.previewButton.frame];
            self.nextButton.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
            [self.previewBackgroundIV addSubview:self.nextButton];
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                temp.transform = CGAffineTransformMakeScale(1.01, 1.01);
                self.previewBackgroundIV.alpha = 1.0;
                self.nextButton.transform = CGAffineTransformMakeScale(1.01, 1.01);
                self.nextButton.alpha = 0.7;
            } completion:^(BOOL finished) {
                [self.previewButton setImage:image forState:UIControlStateNormal];
                [temp removeFromSuperview];
            }];
        }
        
        else if (self.nextButton){ //The next button has been animated in once
            self.previewBackgroundIV.alpha = 1.0;
            [self.previewBackgroundIV insertSubview:temp belowSubview:self.nextButton];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                temp.transform = CGAffineTransformMakeScale(1.01, 1.01);
            } completion:^(BOOL finished) {
                [self.previewButton setImage:image forState:UIControlStateNormal];
                [temp removeFromSuperview];
            }];
        }
        else { //First time the next button has been animated
            self.previewBackgroundIV.alpha = 1.0;
            [self.previewBackgroundIV addSubview:temp];
            
            [self createNextButtonWithFrame:self.previewButton.frame];
            self.nextButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
            [self.previewBackgroundIV addSubview:self.nextButton];
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                self.nextButton.transform = CGAffineTransformMakeScale(1.01, 1.01);
                self.nextButton.alpha = 0.7;
            } completion:^(BOOL finished) {
                [self.previewButton setImage:image forState:UIControlStateNormal];
            }];
        }
    });
}

-(void)configureBottomContainer{
    
    self.bottomOpaqueContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * PHOTO_FRAME_RATIO))];
    self.bottomOpaqueContainer.backgroundColor = [UIColor frescoDefaultBackgroundColor];
    [self.view addSubview:self.bottomOpaqueContainer];
    
    self.bottomClearContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * PHOTO_FRAME_RATIO))];
    self.bottomClearContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bottomClearContainer];
    
    self.bottomOpaqueContainer.layer.shadowOffset = CGSizeMake(0, -1);
    self.bottomOpaqueContainer.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.12].CGColor;
    self.bottomOpaqueContainer.layer.shadowOpacity = 1.0;
    
    [self configureNextSection];
    [self configureApertureButton];
    [self configureFlashButton];
    [self configureToggleView];
    [self setAppropriateIconsForCaptureState];
}

-(void)configureNextSection{
    
    self.previewBackgroundIV = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_PAD, 0, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    self.previewBackgroundIV.image = [UIImage imageNamed:@"white-background-circle"];
    [self.previewBackgroundIV centerVerticallyInView:self.bottomClearContainer];
    self.previewBackgroundIV.userInteractionEnabled = YES;
    self.previewBackgroundIV.alpha = 0.0;
    [self.bottomClearContainer addSubview:self.previewBackgroundIV];
    [self.previewBackgroundIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    
    self.previewButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, PREVIEW_WIDTH - 8, PREVIEW_WIDTH - 8)];
    self.previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.previewButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.previewButton addTarget:self action:@selector(handlePreviewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.previewButton clipAsCircle];
    [self.previewBackgroundIV addSubview:self.previewButton];
    
}

-(void)createNextButtonWithFrame:(CGRect)frame{
    self.nextButton = [[UIButton alloc] initWithFrame:frame];
    [self.nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.nextButton setBackgroundColor:[UIColor whiteColor]];
    [self.nextButton clipAsCircle];
    //    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:700]];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:15]];
    [self.nextButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.nextButton addTarget:self action:@selector(handlePreviewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"highlighted"]){
        
        NSNumber *new = [change objectForKey:@"new"];
        NSNumber *old = [change objectForKey:@"old"];
        
        if ([new isEqualToNumber:@1] && [old isEqualToNumber:@0]){ //Was unhighlighted and then became highlighted
            if (object == self.nextButton)
                self.previewBackgroundIV.alpha = 0.7;
            else if (object == self.flashButton)
                self.flashButton.alpha = 0.7;
        }
        else if ([new isEqualToNumber:@0] && [old isEqualToNumber:@1]){ // Was highlighted and now unhighlighted
            if (object == self.nextButton)
                self.previewBackgroundIV.alpha = 1.0;
            else if (object == self.flashButton)
                self.flashButton.alpha = 1.0;
        }
        else if ([new isEqualToNumber:@1] && [old isEqualToNumber:@1]){ //Was highlighted and is staying highlighted
            if (object == self.nextButton)
                self.previewBackgroundIV.alpha = 0.7;
            else if (object == self.flashButton)
                self.flashButton.alpha = 0.7;
        }
        else {
            if (object == self.nextButton)
                self.previewBackgroundIV.alpha = 1.0;
            else if (object == self.flashButton)
                self.flashButton.alpha = 1.0;
        }
    }
}

-(void)configureApertureButton{
    
    self.apertureShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
    [self.apertureShadowView centerHorizontallyInView:self.bottomClearContainer];
    [self.apertureShadowView centerVerticallyInView:self.bottomClearContainer];
    [self.apertureShadowView addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.bottomClearContainer addSubview:self.apertureShadowView];
    
    self.apertureBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
    self.apertureBackground.layer.cornerRadius = self.apertureBackground.frame.size.width/2.;
    self.apertureBackground.layer.masksToBounds = YES;
    [self.apertureShadowView addSubview:self.apertureBackground];
    
    self.apertureBackground.backgroundColor = [UIColor blueColor];
    
    self.apertureAnimationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    [self.apertureAnimationView centerHorizontallyInView:self.apertureBackground];
    [self.apertureAnimationView centerVerticallyInView:self.apertureBackground];
    self.apertureAnimationView.layer.cornerRadius = 8/2;
    self.apertureAnimationView.layer.masksToBounds = YES;
    self.apertureAnimationView.alpha = 0.0;
    [self.apertureBackground addSubview:self.apertureAnimationView];
    
    
    self.apertureMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.apertureBackground.frame.size.width, self.apertureBackground.frame.size.height)];
    self.apertureMask.backgroundColor = [UIColor clearColor];
    self.apertureMask.layer.borderColor = [UIColor goldApertureColor].CGColor;
    self.apertureMask.layer.borderWidth = 4.0;
    [self.apertureBackground addSubview:self.apertureMask];
    self.apertureMask.layer.cornerRadius = self.apertureMask.frame.size.width/2;
    
    self.originalApertureFrame = CGRectMake(4, 4, APERTURE_WIDTH - 8, APERTURE_WIDTH - 8);
    self.apertureButton = [[UIButton alloc] initWithFrame:self.originalApertureFrame];
    
    self.apertureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH - 8, APERTURE_WIDTH - 8)];
    [self.apertureImageView setImage:[UIImage imageNamed:@"camera-iris"]];
    self.apertureImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.apertureButton addSubview:self.apertureImageView];
    
    [self.apertureMask addSubview:self.apertureButton];
    
    [self.apertureButton addTarget:self action:@selector(handleApertureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)configureFlashButton{
    
    // We start at the edge of the aperture button and then center the view between the aperture button and the recordModeToggleView
    NSInteger apertureEdge = self.apertureShadowView.frame.origin.x + self.apertureShadowView.frame.size.width;
    NSInteger xOrigin = apertureEdge + (self.view.frame.size.width - apertureEdge - SIDE_PAD - (ICON_WIDTH * 2))/2;
    
    NSInteger sidePad = 7;
    
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin - sidePad, -sidePad, ICON_WIDTH + sidePad * 2, ICON_WIDTH + sidePad * 2)];
    [self.flashButton centerVerticallyInView:self.bottomClearContainer];
    [self.flashButton addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    self.flashButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.flashButton.clipsToBounds = YES;
    [self.flashButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.bottomClearContainer addSubview:self.flashButton];
    [self.flashButton addTarget:self action:@selector(flashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

-(void)flashButtonTapped {
    
    //    NSUserDefaults *flash = [NSUserDefaults standardUserDefaults];
    //    [flash setObject:[NSNumber numberWithBool:self.flashIsOn]
    //                         forKey:@"flashIsOn"];
    //
    //    NSUserDefaults *torch = [NSUserDefaults standardUserDefaults];
    //    [torch setObject:[NSNumber numberWithBool:self.torchIsOn]
    //                         forKey:@"torchIsOn"];
    
    
    if (self.captureMode == FRSCaptureModeVideo){
        if (self.torchIsOn == NO) {
            [self torch:YES];
            NSLog(@"torch enabled = %d", self.torchIsOn);
            
            [self.flashButton setImage:[UIImage imageNamed:@"torch-on"] forState:UIControlStateNormal];
            
        } else {
            [self torch:NO];
            NSLog(@"torch disabled = %d", self.torchIsOn);
            
            [self.flashButton setImage:[UIImage imageNamed:@"torch-off"] forState:UIControlStateNormal];
            
        }
        
    } else {
        if (self.flashIsOn == NO ) {
            [self flash:YES];
            NSLog(@"flash enabled = %d", self.flashIsOn);
            
            
            [self.flashButton setImage:[UIImage imageNamed:@"flash-on"] forState:UIControlStateNormal];
            
        } else {
            [self flash:NO];
            NSLog(@"flash disabled = %d", self.flashIsOn);
            
            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
            
        }
    }
}

-(void)torch:(BOOL)on{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (on) {
            [device setTorchMode:AVCaptureTorchModeOn];
            self.torchIsOn = YES;
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            self.torchIsOn = NO;
        }
        [device unlockForConfiguration];
    }
}

-(void)flash:(BOOL)on{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasFlash]) {
        [device lockForConfiguration:nil];
        if (on) {
            [device setFlashMode:AVCaptureFlashModeOn];
            self.flashIsOn = YES;
        } else {
            [device setFlashMode:AVCaptureFlashModeOff];
            self.flashIsOn = NO;
        }
        [device unlockForConfiguration];
    }
}



-(void)configureToggleView{
    
    self.captureModeToggleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (SIDE_PAD * 2) - ICON_WIDTH, self.previewBackgroundIV.frame.origin.y - 4, ICON_WIDTH + SIDE_PAD * 2, self.previewBackgroundIV.frame.size.height + 6)];
    self.captureModeToggleView.userInteractionEnabled = YES;
    [self.bottomClearContainer addSubview:self.captureModeToggleView];
    
    [self configureCameraButton];
    [self configureVideoButton];
    
    UITapGestureRecognizer *toggleGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCaptureMode)];
    [self.captureModeToggleView addGestureRecognizer:toggleGR];
}

-(void)configureCameraButton{
    
    //we offset the y by 2 pixels because the image has top padding on top and we want to align the content of the image.
    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_PAD, 0, ICON_WIDTH, ICON_WIDTH)];
    self.cameraIV.contentMode = UIViewContentModeCenter;
    self.cameraIV.userInteractionEnabled = YES;
    [self.cameraIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.captureModeToggleView addSubview:self.cameraIV];
    
}

-(void)configureVideoButton{
    
    //The ending y coordinate of the thumbnail icon minus the height of the video icon. We add because the image asset itself has bottom padding and we want to align the content of the image.
    NSInteger yOrigin = self.captureModeToggleView.frame.size.height - ICON_WIDTH + 1;
    
    self.videoIV = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_PAD, yOrigin, ICON_WIDTH, ICON_WIDTH)];
    self.videoIV.userInteractionEnabled = YES;
    self.videoIV.contentMode = UIViewContentModeCenter;
    [self.videoIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.captureModeToggleView addSubview:self.videoIV];
    
}

-(void)setAppropriateIconsForCaptureState{
    if (self.captureMode == FRSCaptureModePhoto){
        [self animateShutterExpansionWithColor:[UIColor goldStatusBarColor]];
        
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            
            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
            
            
            self.cameraIV.image = [UIImage imageNamed:@"camera-on"];
            self.videoIV.image = [UIImage imageNamed:@"video-off"];
            
        } completion:^(BOOL finished) {
            self.flashButton.layer.shadowOpacity = 0.0;
            self.cameraIV.layer.shadowOpacity = 0.0;
            self.videoIV.layer.shadowOpacity = 0.0;
        }];
        
    }
    else {
        [self animateShutterExpansionWithColor:[UIColor redCircleStrokeColor]];
        
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            
            [self.flashButton setImage:[UIImage imageNamed:@"torch-off"] forState:UIControlStateNormal];
            
            self.cameraIV.image = [UIImage imageNamed:@"camera-vid-off"];
            self.videoIV.image = [UIImage imageNamed:@"video-vid-on"];
        } completion:^(BOOL finished) {
            self.flashButton.layer.shadowOpacity = 1.0;
            self.cameraIV.layer.shadowOpacity = 1.0;
            self.videoIV.layer.shadowOpacity = 1.0;
        }];
    }
    
}

-(void)animateShutterExpansionWithColor:(UIColor *)color{
    
    self.apertureAnimationView.backgroundColor = color;
    self.apertureAnimationView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.apertureAnimationView.frame = CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH);
        self.apertureAnimationView.layer.cornerRadius = APERTURE_WIDTH/2.0;
        
    } completion:^(BOOL finished) {
        self.apertureAnimationView.alpha = 0.0;
        self.apertureAnimationView.frame = CGRectMake(0, 0, 8, 8);
        self.apertureAnimationView.center = self.apertureBackground.center;
        self.apertureAnimationView.layer.cornerRadius = 4;
        self.apertureBackground.backgroundColor = color;
        self.apertureMask.layer.borderColor = color.CGColor;
    }];
    
}

-(void)adjustFramesForCaptureState{
    
    NSInteger topToAperture = (self.bottomClearContainer.frame.size.height - self.apertureBackground.frame.size.height)/2;
    NSInteger offset = topToAperture - 10;
    
    CGRect bigPreviewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGRect smallPreviewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * PHOTO_FRAME_RATIO);
    
    if (self.captureMode == FRSCaptureModePhoto){
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.preview.frame = smallPreviewFrame;
            self.captureVideoPreviewLayer.frame = self.preview.bounds;
            self.bottomOpaqueContainer.frame = CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.bottomOpaqueContainer.frame.size.width, self.bottomOpaqueContainer.frame.size.height);
            self.bottomClearContainer.frame = CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.bottomClearContainer.frame.size.width, self.bottomClearContainer.frame.size.height);
        } completion:^(BOOL finished){
            self.apertureButton.frame = self.originalApertureFrame;
        }];
    }
    else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.preview.frame = bigPreviewFrame;
            self.captureVideoPreviewLayer.frame = bigPreviewFrame;
            self.bottomOpaqueContainer.frame = CGRectMake(0, self.view.frame.size.height, self.bottomOpaqueContainer.frame.size.width, self.bottomOpaqueContainer.frame.size.height);
            self.bottomClearContainer.frame = CGRectMake(0, self.bottomClearContainer.frame.origin.y + offset, self.bottomClearContainer.frame.size.width, self.bottomClearContainer.frame.size.height);
        } completion:^(BOOL finished){
            self.apertureButton.frame = self.originalApertureFrame;
        }];
    }
}

-(void)rotateApp:(NSNotification *)notif{
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    CGFloat angle = 0;
    NSInteger labelWidth;
    NSInteger offset = 12 + self.closeButton.frame.size.width + 17 + self.locationIV.frame.size.width + 7 + 12;
    if ( o == UIDeviceOrientationLandscapeLeft ){
        angle = M_PI_2;
        labelWidth = self.captureVideoPreviewLayer.frame.size.height;
        [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topContainer.alpha = 0;
        } completion:nil];
        [UIView animateWithDuration:0.1 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topContainer.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(self.view.center.x - (ICON_WIDTH), (self.view.center.x - (ICON_WIDTH))),angle);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.topContainer.alpha = 1;
            } completion:nil];
        }];
        
    } else if ( o == UIDeviceOrientationLandscapeRight ){
        angle = -M_PI_2;
        labelWidth = self.captureVideoPreviewLayer.frame.size.height;
        [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topContainer.alpha = 0;
        } completion:nil];
        [UIView animateWithDuration:0.1 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topContainer.transform = CGAffineTransformRotate((CGAffineTransformMakeTranslation (self.view.center.x - (self.view.center.x *2) + (ICON_WIDTH), self.view.center.y - (ICON_WIDTH ))),angle);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.topContainer.alpha = 1;
            } completion:nil];
        }];
        [UIView animateWithDuration:0.1 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.topContainer.transform = CGAffineTransformRotate((CGAffineTransformMakeTranslation (self.view.center.x - (self.view.center.x *2) + (ICON_WIDTH), self.view.center.y - (ICON_WIDTH * 2))),angle);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.topContainer.alpha = 1;
            } completion:nil];
        }];
        
    } else if ( o == UIDeviceOrientationPortraitUpsideDown ){
        /* no longer supported */
        labelWidth = self.captureVideoPreviewLayer.frame.size.width;
        return;
        
    } else if ( o == UIDeviceOrientationPortrait ){
        labelWidth = self.captureVideoPreviewLayer.frame.size.width;
        [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topContainer.alpha = 0;
        } completion:nil];
        [UIView animateWithDuration:0.1 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topContainer.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, 0), angle);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.topContainer.alpha = 1;
            } completion:nil];
        }];
    } else {
        return;
    }
    
    [UIView beginAnimations:@"omar" context:nil];
    [UIView setAnimationDuration:0.2];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    self.cameraIV.transform = rotation;
    self.videoIV.transform = rotation;
    self.flashButton.transform = rotation;
    self.apertureBackground.transform = rotation;
    self.previewBackgroundIV.transform = rotation;

    [UIView commitAnimations];
    
    self.assignmentLabel.frame = CGRectMake(self.assignmentLabel.frame.origin.x, self.assignmentLabel.frame.origin.y, labelWidth - offset, self.assignmentLabel.frame.size.height);
}

-(void)animateShutterWithCompletion:(void(^)())completion{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.apertureButton.transform = CGAffineTransformMakeRotation(M_PI/-2);
        } completion:nil];
        
        [UIView animateWithDuration:0.15 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.apertureButton.transform = CGAffineTransformMakeScale(4.00, 4.00);
        }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.15 delay:0.06 options: UIViewAnimationOptionCurveEaseOut animations:^{
                                 self.apertureButton.transform = CGAffineTransformMakeScale(1.00, 1.00);
                             } completion:^(BOOL finished){
                                 self.apertureButton.frame = self.originalApertureFrame;
                             }];
                         }];
    });
}




#pragma mark - Button action handlers

-(void)handleApertureButtonTapped:(UIButton *)button{
    
    if (self.captureMode == FRSCaptureModePhoto){
        
        [self captureStillImage];
    }
    else {
        [self toggleVideoRecording];
        
    }
    
    
}

//=======
//#pragma mark - Button action handlers
//
//-(void)handleApertureButtonTapped:(UIButton *)button{
//    if (self.captureMode == FRSCaptureModePhoto){
//        [self captureStillImage];
//    }
//    else {
//        [self toggleVideoRecording];
//>>>>>>> 97a0ccb8a862368e56875c9feb62ba4a16252c1e
//    }
//}

-(void)toggleCaptureMode{
    
    /* Disables torch when returning from video toggle and torch is enabled */
    [self torch:NO];
    
    /* Disable mask for transition animation */
    self.apertureMask.layer.borderColor = [UIColor clearColor].CGColor;
    
    if (self.captureMode == FRSCaptureModePhoto){
        self.captureMode = FRSCaptureModeVideo;
        //        self.cameraDisabled = YES;
        self.apertureImageView.alpha = 1;
        
        /* Delay is used to change color of mask after animation completes */
        
        [self.sessionManager.session beginConfiguration];
        
        //Change the preset to display properly
        if ([self.sessionManager.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            //Set the session preset to photo, the default mode we enter in as
            [self.sessionManager.session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        
        [self.sessionManager.session commitConfiguration];
        
    }
    else {
        self.captureMode = FRSCaptureModePhoto;
        /* Delay is used to change color of mask after animation completes */
        
        
        [self.sessionManager.session beginConfiguration];
        
        //Change the preset to display properly
        if ([self.sessionManager.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            //Set the session preset to photo, the default mode we enter in as
            [self.sessionManager.session setSessionPreset:AVCaptureSessionPresetPhoto];
        }
        
        [self.sessionManager.session commitConfiguration];
        
    }
    
    [self setAppropriateIconsForCaptureState];
    [self adjustFramesForCaptureState];
}

#pragma mark - Notifications and Observers

-(void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateApp:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Camera focus

-(void)handleTapToFocus:(UITapGestureRecognizer *)gr{
    CGPoint devicePoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:[gr locationInView:gr.view]];
    
    CGPoint rawPoint = [gr locationInView:gr.view];
    [self playFocusAnimationAtPoint:rawPoint];
    
    [self.sessionManager focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
    
}

-(void)playFocusAnimationAtPoint:(CGPoint)devicePoint{
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    circle.backgroundColor = [UIColor clearColor];
    circle.layer.borderColor = [UIColor whiteColor].CGColor;
    circle.layer.borderWidth = 2.0;
    circle.alpha = 0.0;
    circle.center = devicePoint;
    circle.layer.cornerRadius = circle.frame.size.height/2;
    circle.clipsToBounds = YES;
    
    [self.preview addSubview:circle];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        circle.alpha = 1.0;
        circle.transform = CGAffineTransformMakeScale(0.6, 0.6);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             circle.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [circle removeFromSuperview];
                             });
                         }];
    }];
}



#pragma mark - Capture data processing

-(void)captureStillImage{
    dispatch_async(self.sessionManager.sessionQueue, ^{
        
        if(self.capturingImage)
            return;
        else {
            self.capturingImage = YES;
            self.previewButton.userInteractionEnabled = NO;
            self.nextButton.userInteractionEnabled = NO;
        }
        
        AVCaptureConnection *connection = [self.sessionManager.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // Update the orientation on the still image output video connection before capturing.
        connection.videoOrientation = [self orientationFromDeviceOrientaton];
        
        // Capture a still image.
        
        [self animateShutterWithCompletion:nil];
        
        [self.sessionManager.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
            
            CMSampleBufferRef copy = NULL;
            CMSampleBufferCreateCopy(NULL, imageDataSampleBuffer, &copy);
            
            if (copy){
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
                    NSData *imageNSData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:copy];
                    
                    if (imageNSData) {
                        
                        CGImageSourceRef imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageNSData, NULL);
                        
                        //make the metadata dictionary mutable so we can add properties to it
                        NSMutableDictionary *metadata = [(__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL) mutableCopy];
                        
                        NSMutableDictionary *GPSDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
                        
                        if(!GPSDictionary)
                            GPSDictionary = [[self.locationManager.location EXIFMetadata] mutableCopy];
                        
                        
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
                            
                            self.capturingImage = NO;
                            self.previewButton.userInteractionEnabled = YES;
                            self.nextButton.userInteractionEnabled = YES;
                            
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
                                            self.capturingImage = NO;
                                            self.previewButton.userInteractionEnabled = YES;
                                            self.nextButton.userInteractionEnabled = YES;
                                        }
                                        else {
                                            [self updatePreviewButtonWithImage:[UIImage imageWithData:newImageData scale:.1]];
                                            self.capturingImage = NO;
                                            self.previewButton.userInteractionEnabled = YES;
                                            self.nextButton.userInteractionEnabled = YES;
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
                                            [self updatePreviewButtonWithImage:[UIImage imageWithData:newImageData scale:.1]];
                                            
                                        }
                                        
                                        self.capturingImage = NO;
                                        self.previewButton.userInteractionEnabled = YES;
                                        self.nextButton.userInteractionEnabled = YES;
                                        
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
                });
            }
            else {
                NSLog( @"Could not capture still image: %@", error );
            }
        }];
    });
}

-(void)toggleVideoRecording{
    
    if (self.sessionManager.movieFileOutput.isRecording) {
        
        //Clear the timer so it doesn't re-run
        [self.videoTimer invalidate];
        self.videoTimer = nil;
        
        [self stopRecordingAnimation];
        self.previewBackgroundIV.alpha = 1.0;
        
    }
    else {
        self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_VIDEO_LENGTH target:self selector:@selector(videoEnded:) userInfo:nil repeats:NO];
    }
    
    dispatch_async(self.sessionManager.sessionQueue, ^{
        
        if (!self.sessionManager.movieFileOutput.isRecording) {
            
            AVCaptureConnection *movieConnection = [self.sessionManager.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (!movieConnection){
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
                item.value = [NSString stringWithFormat:@"%+08.4lf%+09.4lf/", [FRSLocationManager sharedManager].location.coordinate.latitude, [FRSLocationManager sharedManager].location.coordinate.longitude];
                self.sessionManager.movieFileOutput.metadata = @[item];
                
                if ( [UIDevice currentDevice].isMultitaskingSupported ) {
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
            
        }
        else {
            [self.sessionManager.movieFileOutput stopRecording];
        }
    });
}

- (void)videoEnded:(NSTimer *)timer{
    [self toggleVideoRecording];
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
                        
                        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.previewBackgroundIV.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
                            
                            [self updatePreviewButtonWithImage:result];
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



-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    [self.nextButton removeObserver:self forKeyPath:@"highlighted"];
    [self.flashButton removeObserver:self forKeyPath:@"highlighted"];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    if (self.locationManager.managerState == LocationManagerStateForeground)
        [self.locationManager stopUpdatingLocation];
    
    if (self.locationManager.location) {
        
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:20 ofLocation:[FRSLocationManager sharedManager].location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
            
            if([responseObject firstObject] != nil){
                
                FRSAssignment *assignment = [responseObject firstObject];
                
                CGFloat distanceInMiles = [[FRSLocationManager sharedManager].location distanceFromLocation:assignment.locationObject] / kMetersInAMile;
                
                //Check if in range
                if(distanceInMiles < [assignment.radius floatValue]){
                    
                    [self updateLocationLabelWithAssignment:assignment];
                    
                    //                    [self toggleAssignmentLabel:YES];
                    
                }
            }
        }];
    }
    
    [self.locationManager setupLocationMonitoringForState:LocationManagerStateBackground];
    
}

-(void)updateLocationLabelWithAssignment:(FRSAssignment *)assignment{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!assignment.title)
            return;
        self.assignmentLabel.text = [assignment.title uppercaseString];
        
        [UIView animateWithDuration:0.15 animations:^{
            self.locationIV.alpha = 1.0;
            self.assignmentLabel.alpha = 1.0;
        }];
    });
}


- (void)runVideoRecordAnimation{
    
    self.captureModeToggleView.alpha = 0.0;
    
    [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.apertureButton.transform = CGAffineTransformMakeRotation(M_PI/-2);
    } completion:nil];
    
    [UIView animateWithDuration:0.25 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.apertureButton.transform = CGAffineTransformMakeScale(4.00, 4.00);
    }
                     completion:nil];
    
    self.previewBackgroundIV.alpha = 0.0;
    
    int radius = 30;
    self.circleLayer = [CAShapeLayer layer];
    // Make a circular shape
    
    
    self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                       cornerRadius:radius].CGPath;
    
    self.circleLayer.position = CGPointMake (CGRectGetMidX(self.apertureBackground.frame)-30, 6);
    
    // Configure the apperence of the circle
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleLayer.lineWidth = 4;
    
    // Add to parent layer
    [self.apertureBackground.layer addSublayer:self.circleLayer];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration = MAX_VIDEO_LENGTH; // for testing purposes
    //    drawAnimation.duration            = MAX_VIDEO_LENGTH; //Animate ove max vid length
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // Add the animation to the circle
    [self.circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
    //    }
    
    
}

-(void)stopRecordingAnimation {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
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
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.apertureButton.transform = CGAffineTransformMakeRotation(M_PI);
                             
                             
                         }
                         completion:^(BOOL finished){
                             self.captureModeToggleView.alpha = 1.0;
                         }];
    });
}

#pragma mark - Navigation

-(void)handlePreviewButtonTapped{
    
    if (self.sessionManager.movieFileOutput.isRecording){
        [self toggleVideoRecording];
    }
    
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:[[AssetsPickerController alloc] init]];
    
    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:navVC animated:NO completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(AVCaptureVideoOrientation)orientationFromDeviceOrientaton{
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

/*er
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
