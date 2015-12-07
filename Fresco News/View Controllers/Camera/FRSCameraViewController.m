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

//Root View Controller
#import "FRSRootViewController.h"



#define ICON_WIDTH 24
#define PREVIEW_WIDTH 56
#define APERTURE_WIDTH 72
#define SIDE_PAD 12
#define PHOTO_FRAME_RATIO 4/3

typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModePhoto,
    FRSCaptureModeVideo
};


@interface FRSCameraViewController () <CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) FRSAVSessionManager *sessionManager;
@property (strong, nonatomic) FRSLocationManager *locationManager;
@property (strong, nonatomic) FRSGalleryAssetsManager *assetsManager;

@property (strong, nonatomic) UIView *preview;

@property (strong, nonatomic) UIView *bottomClearContainer;
@property (strong, nonatomic) UIView *bottomOpaqueContainer;

@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIView *apertureShadowView;
@property (strong, nonatomic) UIView *apertureAnimationView;
@property (strong, nonatomic) UIView *apertureBackground;
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

@property (nonatomic) FRSCaptureMode captureMode;
@property (nonatomic) UIDeviceOrientation currentOrientation;

@property (strong, nonatomic) FRSAssignment *defaultAssignment;

@property (nonatomic) BOOL capturingImage;

@property (nonatomic) BOOL flashIsOn;
@property (nonatomic) BOOL torchIsOn;

@property (strong, nonatomic) NSTimer *videoTimer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic) BOOL firstTime;

@end

@implementation FRSCameraViewController

-(instancetype)init{
    self = [super init];
    if (self){
        self.sessionManager = [FRSAVSessionManager defaultManager];
        self.locationManager = [FRSLocationManager sharedManager];
        self.assetsManager = [FRSGalleryAssetsManager sharedManager];
        
//        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.captureMode = FRSCaptureModePhoto;
        self.currentOrientation = [UIDevice currentDevice].orientation;
        
        self.firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    //hide status bar before view is loaded.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [super viewDidLoad];

    [self configureUI];
    
    [self.sessionManager startCaptureSession];
    
    [self addObservers];
    
    [[FRSGalleryAssetsManager sharedManager] fetchGalleryAssetsInBackgroundWithCompletion:^{
            [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    status == PHAuthorizationStatusAuthorized ? [self updatePreviewButtonWithAsset] : [self updatePreviewButtonWithImage:[UIImage imageNamed:@"camera-roll"]];
                });
            }];
    }];
    
    [self.locationManager setupLocationMonitoringForState:LocationManagerStateForeground];
    self.locationManager.delegate = self;
    
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.sessionManager.AVSetupSuccess){
        dispatch_async(self.sessionManager.sessionQueue, ^{
            //        [self addObservers];
            [self.sessionManager.session startRunning];
            [self fadeInPreview];
        });
    }
    else {
        
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.locationManager stopLocationUpdates];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.sessionManager clearCaptureSession];
    

}

-(void)fadeInPreview{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"FADE IN PREVIEW CALLED");
            self.preview.alpha = 1.0;
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
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 0, 24, 24)];
    [self.closeButton setImage:[UIImage imageNamed:@"x-icon-light"] forState:UIControlStateNormal];
    [self.closeButton addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.closeButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.topContainer addSubview:self.closeButton];
    
    self.locationIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.closeButton.frame.origin.x + self.closeButton.frame.size.width + 17, 1, 22, 22)];
    self.locationIV.contentMode = UIViewContentModeScaleAspectFit;
    self.locationIV.image = [UIImage imageNamed:@"crosshairs-icon"];
    [self.locationIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.topContainer addSubview:self.locationIV];
    
    self.assignmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.locationIV.frame.origin.x + self.locationIV.frame.size.width + 7, 0, [self assignmentLabelWidth], 24)];
    self.assignmentLabel.textColor = [UIColor whiteColor];
    self.assignmentLabel.font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:15];
    self.assignmentLabel.text = [@"This is a test label with some text bitch" uppercaseString];
    [self.assignmentLabel addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.topContainer addSubview:self.assignmentLabel];
    
}

-(NSInteger)assignmentLabelWidth{
    return self.view.frame.size.width - self.closeButton.frame.size.width - self.locationIV.frame.size.width - 10 - 17 - 7 - 12;
}

-(void)configurePreview{
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * PHOTO_FRAME_RATIO)];
    self.preview.backgroundColor = [UIColor blackColor];
    
    CALayer *viewLayer = self.preview.layer;
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [viewLayer addSublayer:self.captureVideoPreviewLayer];
    self.captureVideoPreviewLayer.frame = self.preview.bounds;
    
    UITapGestureRecognizer *focusGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
    [self.preview addGestureRecognizer:focusGR];
    
    [self.view addSubview:self.preview];
}

-(void)updatePreviewButtonWithAsset{
    PHAsset *asset = [self.assetsManager.fetchResult firstObject];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.previewButton.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result){
            self.previewBackgroundIV.alpha = 0;
        }
        else {
            self.previewBackgroundIV.alpha = 1.0;
            self.whiteView.alpha = 0.0;
            [self.previewButton setImage:result forState:UIControlStateNormal];
            if (!self.firstTime) {
                self.whiteView.alpha = 0.7;
                [self.nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
            }
            self.firstTime = NO;
        }
    }];
}

-(void)updatePreviewButtonWithImage:(UIImage *)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewBackgroundIV.alpha = 1.0;
        [self.previewButton setImage:image forState:UIControlStateNormal];
    });
}

-(void)configureBottomContainer{
    
    
    self.bottomOpaqueContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * PHOTO_FRAME_RATIO))];
    self.bottomOpaqueContainer.backgroundColor = [UIColor frescoDefaultBackgroundColor];
    [self.view addSubview:self.bottomOpaqueContainer];
    
    self.bottomClearContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * PHOTO_FRAME_RATIO))];
    self.bottomClearContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bottomClearContainer];
    
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
    
    
    [self.previewButton clipAsCircle];
    
    [self.previewBackgroundIV addSubview:self.previewButton];
    
    self.whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.alpha = 0.0;
    self.whiteView.layer.cornerRadius = self.whiteView.frame.size.width/2;
    self.whiteView.clipsToBounds = YES;
    [self.previewBackgroundIV addSubview:self.whiteView];
    
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.previewBackgroundIV.frame.size.width, self.previewBackgroundIV.frame.size.height)];
    [self.nextButton setTitle:@"" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:700]];
    [self.previewBackgroundIV addSubview:self.nextButton];
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
    self.apertureBackground.layer.cornerRadius = APERTURE_WIDTH/2.;
    self.apertureBackground.layer.masksToBounds = YES;
    [self.apertureShadowView addSubview:self.apertureBackground];
    
    self.apertureAnimationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.apertureAnimationView.layer.cornerRadius = 8/2;
    self.apertureAnimationView.layer.masksToBounds = YES;
    self.apertureAnimationView.alpha = 0.0;
    [self.apertureBackground addSubview:self.apertureAnimationView];
    
    
    self.apertureButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, APERTURE_WIDTH - 8, APERTURE_WIDTH - 8)];
    self.apertureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;

    
    [self.apertureButton setImage:[UIImage imageNamed:@"camera-iris"] forState:UIControlStateNormal];
    [self.apertureButton setImage:[[UIImage imageNamed:@"camera-iris"] tintedImageWithColor:[UIColor colorWithWhite:1.0 alpha:0.7] blendingMode:kCGBlendModeOverlay] forState:UIControlStateHighlighted];
    

    [self.apertureBackground addSubview:self.apertureButton];
    
    [self.apertureButton addTarget:self action:@selector(handleApertureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.apertureButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}


-(void)configureFlashButton{
    
    // We start at the edge of the aperture button and then center the view between the aperture button and the recordModeToggleView
    NSInteger apertureEdge = self.apertureShadowView.frame.origin.x + self.apertureShadowView.frame.size.width;
    NSInteger xOrigin = apertureEdge + (self.view.frame.size.width - apertureEdge - SIDE_PAD - (ICON_WIDTH * 2))/2;
    
    
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin, 0, ICON_WIDTH, ICON_WIDTH)];
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
    self.captureModeToggleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - SIDE_PAD - ICON_WIDTH, self.previewBackgroundIV.frame.origin.y - 3, ICON_WIDTH, self.previewBackgroundIV.frame.size.height + 3)];
    self.captureModeToggleView.userInteractionEnabled = YES;
    [self.bottomClearContainer addSubview:self.captureModeToggleView];
    
    [self configureCameraButton];
    [self configureVideoButton];
    
    UITapGestureRecognizer *toggleGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCaptureMode)];
    [self.captureModeToggleView addGestureRecognizer:toggleGR];
}

-(void)configureCameraButton{
    
    //we offset the y by 2 pixels because the image has top padding on top and we want to align the content of the image.
    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)];
    self.cameraIV.contentMode = UIViewContentModeCenter;
    self.cameraIV.userInteractionEnabled = YES;
    [self.cameraIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.captureModeToggleView addSubview:self.cameraIV];

}

-(void)configureVideoButton{
    
    //The ending y coordinate of the thumbnail icon minus the height of the video icon. We add because the image asset itself has bottom padding and we want to align the content of the image.
    NSInteger yOrigin = self.captureModeToggleView.frame.size.height - ICON_WIDTH + 4;
    
    self.videoIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOrigin, ICON_WIDTH, ICON_WIDTH)];
    self.videoIV.userInteractionEnabled = YES;
    self.videoIV.contentMode = UIViewContentModeCenter;
    [self.videoIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.captureModeToggleView addSubview:self.videoIV];
    
//    self.videoIV.backgroundColor = [UIColor orangeColor]; //For testing purposes;
}

-(void)setAppropriateIconsForCaptureState{
    if (self.captureMode == FRSCaptureModePhoto){
        [self animateShutterExpansionWithColor:[UIColor goldStatusBarColor]];
        
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{

            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
//            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateHighlighted];

            
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
        self.apertureAnimationView.layer.cornerRadius = APERTURE_WIDTH/2,0;
        
    } completion:^(BOOL finished) {
        self.apertureAnimationView.alpha = 0.0;
        self.apertureAnimationView.frame = CGRectMake(0, 0, 8, 8);
        self.apertureAnimationView.center = self.apertureBackground.center;
        self.apertureAnimationView.layer.cornerRadius = 4;
        self.apertureBackground.backgroundColor = color;
    }];
}

-(void)adjustFramesForCaptureState{
    
    NSInteger topToAperture = (self.bottomClearContainer.frame.size.height - self.apertureBackground.frame.size.height)/2;
    NSInteger offset = topToAperture - 10;
    
    if (self.captureMode == FRSCaptureModePhoto){
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * PHOTO_FRAME_RATIO);
            self.captureVideoPreviewLayer.frame = self.preview.bounds;
            self.bottomOpaqueContainer.frame = CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.bottomOpaqueContainer.frame.size.width, self.bottomOpaqueContainer.frame.size.height);
            self.bottomClearContainer.frame = CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.bottomClearContainer.frame.size.width, self.bottomClearContainer.frame.size.height);
        } completion:nil];
    }
    else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.captureVideoPreviewLayer.frame = self.preview.bounds;
            self.bottomOpaqueContainer.frame = CGRectMake(0, self.view.frame.size.height, self.bottomOpaqueContainer.frame.size.width, self.bottomOpaqueContainer.frame.size.height);
            self.bottomClearContainer.frame = CGRectMake(0, self.bottomClearContainer.frame.origin.y + offset, self.bottomClearContainer.frame.size.width, self.bottomClearContainer.frame.size.height);
        } completion:nil];
    }
}

-(void)rotateApp:(NSNotification *)notif{
    NSLog(@"orientation from %lu to %lu", self.currentOrientation, [UIDevice currentDevice].orientation);
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
//            NSLog(@"from %lu to lu", self.currentOrientation, [UIDevice currentDevice].orientation)
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            
            break;
        case UIDeviceOrientationLandscapeLeft:
            
            break;
        case UIDeviceOrientationLandscapeRight:
            break;
        default:
            break;
    }
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

-(void)toggleCaptureMode{
    
    /* Disables torch when returning from video toggle and torch is enabled */
    [self torch:NO];
    
    if (self.captureMode == FRSCaptureModePhoto){
        self.captureMode = FRSCaptureModeVideo;
        
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
    UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    square.backgroundColor = [UIColor clearColor];
    square.layer.borderColor = [UIColor brandDarkColor].CGColor;
    square.layer.borderWidth = 4.0;
    square.alpha = 1.0;
    square.center = devicePoint;
    
    [self.preview addSubview:square];
    
    [UIView animateWithDuration:0.2 animations:^{
        square.transform = CGAffineTransformMakeScale(0.5, 0.5);
    } completion:^(BOOL finished) {
        [square removeFromSuperview];
    }];
}



#pragma mark - Capture data processing

-(void)captureStillImage{
    dispatch_async(self.sessionManager.sessionQueue, ^{
        
        if(self.capturingImage)
            return;
        else
            self.capturingImage = YES;
        
        AVCaptureConnection *connection = [self.sessionManager.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if (!connection){
            [self.sessionManager.session beginConfiguration];
            
            //Change the preset to display properly
            if ([self.sessionManager.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
                //Set the session preset to photo, the default mode we enter in as
                [self.sessionManager.session setSessionPreset:AVCaptureSessionPresetPhoto];
            }
            
            [self.sessionManager.session commitConfiguration];
        }
        
        connection = [self.sessionManager.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        // Update the orientation on the still image output video connection before capturing.
        connection.videoOrientation = self.captureVideoPreviewLayer.connection.videoOrientation;
        
        // Capture a still image.
        [self.sessionManager.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
            
            self.capturingImage = NO;
            
            if (imageDataSampleBuffer ) {
                
                NSData *imageNSData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
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
                                    [self updatePreviewButtonWithImage:[UIImage imageWithData:newImageData scale:.1]];
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

-(void)toggleVideoRecording{
    if (self.sessionManager.movieFileOutput.isRecording) {
        
        //Clear the timer so it doesn't re-run
        [self.videoTimer invalidate];
        self.videoTimer = nil;
        
        self.captureModeToggleView.alpha = 1.0;
        
    }
    else {
        
        self.captureModeToggleView.alpha = 0.0;
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
                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.captureVideoPreviewLayer;
                connection.videoOrientation = previewLayer.connection.videoOrientation;
                
                // Start recording to a temporary file.
                NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
                [self.sessionManager.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                [self.sessionManager.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                
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
    [self.apertureButton removeObserver:self forKeyPath:@"highlighted"];
    [self.flashButton removeObserver:self forKeyPath:@"highlighted"];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    if (self.locationManager.managerState == LocationManagerStateForeground)
        [self.locationManager stopUpdatingLocation];

    NSLog(@"did update locations in camera, %@", self.locationManager.location);
    
    if (self.locationManager.location && self.defaultAssignment == nil) {
        
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:20 ofLocation:[FRSLocationManager sharedManager].location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
            
            if([responseObject firstObject] != nil){
                
                FRSAssignment *assignment = [responseObject firstObject];
                
                CGFloat distanceInMiles = [[FRSLocationManager sharedManager].location distanceFromLocation:assignment.locationObject] / kMetersInAMile;
                
                //Check if in range
                if(distanceInMiles < [assignment.radius floatValue]){
                    
                    self.defaultAssignment = assignment;
                    
//                    [self toggleAssignmentLabel:YES];
                }
                
            }
        }];
    }
}


#pragma mark - Navigation

-(void)dismissVC{
    
    NSLog(@"dismissVC");
    
    //    [self.frsRootViewController setRootViewControllerToTabBar];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)handlePreviewButtonTapped{
    
    BaseNavigationController *navVC = [[BaseNavigationController alloc] initWithRootViewController:[[AssetsPickerController alloc] init]];
    
    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:navVC animated:NO completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
