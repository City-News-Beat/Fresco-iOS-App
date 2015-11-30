//
//  FRSCameraViewController.m
//  Fresco
//
//  Created by Daniel Sun on 11/13/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSCameraViewController.h"

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

//Models
#import "FRSAssignment.h"
#import "CLLocation+EXIFGPS.h"



#define ICON_WIDTH 24
#define PREVIEW_WIDTH 56
#define APERTURE_WIDTH 72
#define SIDE_PAD 12
#define PHOTO_FRAME_RATIO 4/3

typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModePhoto,
    FRSCaptureModeVideo
};


@interface FRSCameraViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) FRSAVSessionManager *sessionManager;
@property (strong, nonatomic) FRSLocationManager *locationManager;
@property (strong, nonatomic) FRSGalleryAssetsManager *assetsManager;

@property (strong, nonatomic) UIView *preview;

@property (strong, nonatomic) UIView *bottomContainer;

@property (strong, nonatomic) UIView *aperatureShadowView;
@property (strong, nonatomic) UIView *apertureBackground;
@property (strong, nonatomic) UIButton *apertureButton;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIImageView *previewBackgroundIV;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (strong, nonatomic) UIView *recordingModeToggleView;
@property (strong, nonatomic) UIImageView *cameraIV;
@property (strong, nonatomic) UIImageView *videoIV;

@property (strong, nonatomic) UIButton *flashButton;

@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) UIView *whiteView;

@property (nonatomic) FRSCaptureMode captureMode;
@property (nonatomic) UIDeviceOrientation currentOrientation;

@property (strong, nonatomic) FRSAssignment *defaultAssignment;

@property (nonatomic) BOOL capturingImage;


@end

@implementation FRSCameraViewController

-(instancetype)init{
    self = [super init];
    if (self){
        self.sessionManager = [FRSAVSessionManager defaultManager];
        self.locationManager = [FRSLocationManager sharedManager];
        self.assetsManager = [FRSGalleryAssetsManager sharedManager];
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.captureMode = FRSCaptureModePhoto;
        self.currentOrientation = [UIDevice currentDevice].orientation;
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
    
    //TEMPORARY
//    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 50, 50)];
        close.backgroundColor = [UIColor orangeColor];
        [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomContainer addSubview:close];
//    });
    
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
}

-(void)fadeInPreview{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.preview.alpha == 0){
            [UIView animateWithDuration:0.4 animations:^{
                self.preview.alpha = 1.0;
            }];
        }
    });
}


#pragma mark - UI configuration methods

-(void)configureUI{
    
    [self configurePreview];
    [self configureBottomContainer];
}

-(void)configurePreview{
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * PHOTO_FRAME_RATIO)];
    self.preview.backgroundColor = [UIColor blackColor];
    
    CALayer *viewLayer = self.preview.layer;     self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.session];
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
            [self.previewButton setImage:result forState:UIControlStateNormal];
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
    
    self.bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * PHOTO_FRAME_RATIO, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * PHOTO_FRAME_RATIO))];
    self.bottomContainer.backgroundColor = [UIColor frescoDefaultBackgroundColor];
    [self.view addSubview:self.bottomContainer];
    
    [self configureNextSection];
    [self configureApertureButton];
    [self configureFlashButton];
    [self configureToggleView];
}

-(void)configureNextSection{
    
//    self.previewView = [[FRSRoundedView alloc] initWithImage:[UIImage imageNamed:@"twitter-b"] borderWidth:4.0];
//    self.previewView.frame = CGRectMake(SIDE_PAD, 0, PREVIEW_WIDTH, PREVIEW_WIDTH);
//    [self.previewView centerVerticallyInView:self.bottomContainer];
    
    self.previewBackgroundIV = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_PAD, 0, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    self.previewBackgroundIV.image = [UIImage imageNamed:@"white-background-circle"];
    [self.previewBackgroundIV centerVerticallyInView:self.bottomContainer];
    self.previewBackgroundIV.userInteractionEnabled = YES;
    self.previewBackgroundIV.alpha = 0.0;
    [self.bottomContainer addSubview:self.previewBackgroundIV];
    [self.previewBackgroundIV addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    
    
    self.previewButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, PREVIEW_WIDTH - 8, PREVIEW_WIDTH - 8)];
    self.previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.previewButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.previewButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self.previewButton clipAsCircle];
    
    
    [self.previewBackgroundIV addSubview:self.previewButton];
    
    self.whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.alpha = 0;
    self.whiteView.layer.cornerRadius = self.whiteView.frame.size.width/2;
    self.whiteView.clipsToBounds = YES;
    [self.previewBackgroundIV addSubview:self.whiteView];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"highlighted"]){
        
        NSNumber *new = [change objectForKey:@"new"];
        NSNumber *old = [change objectForKey:@"old"];
        
        if ([new isEqualToNumber:@1] && [old isEqualToNumber:@0]){ //Was unhighlighted and then became highlighted
            self.whiteView.alpha = 0.4;
        }
        else if ([new isEqualToNumber:@0] && [old isEqualToNumber:@1]){ // Was highlighted and now unhighlighted
            self.whiteView.alpha = 0.0;
        }
        else if ([new isEqualToNumber:@1] && [old isEqualToNumber:@1]){ //Was highlighted and is staying highlighted
            self.whiteView.alpha = 0.4;
        }
        else {
            self.whiteView.alpha = 0.0;
        }
    }
}

-(void)configureApertureButton{
    
    self.aperatureShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
    [self.aperatureShadowView centerHorizontallyInView:self.bottomContainer];
    [self.aperatureShadowView centerVerticallyInView:self.bottomContainer];
    [self.aperatureShadowView addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.bottomContainer addSubview:self.aperatureShadowView];
    
    self.apertureBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
    self.apertureBackground.backgroundColor = [UIColor goldStatusBarColor];
    self.apertureBackground.layer.cornerRadius = APERTURE_WIDTH/2.;
    self.apertureBackground.layer.masksToBounds = YES;
    [self.aperatureShadowView addSubview:self.apertureBackground];
    
    
    self.apertureButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, APERTURE_WIDTH - 8, APERTURE_WIDTH - 8)];
    self.apertureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.apertureButton setImage:[UIImage imageNamed:@"camera-iris"] forState:UIControlStateNormal];

    [self.apertureBackground addSubview:self.apertureButton];
    
    [self.apertureButton addTarget:self action:@selector(handleApertureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)configureFlashButton{
    
    
    // We start at the edge of the aperture button and then center the view between the aperture button and the recordModeToggleView
    NSInteger apertureEdge = self.aperatureShadowView.frame.origin.x + self.aperatureShadowView.frame.size.width;
    NSInteger xOrigin = apertureEdge + (self.view.frame.size.width - apertureEdge - SIDE_PAD - (ICON_WIDTH * 2))/2;
    
    
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin, 0, ICON_WIDTH, ICON_WIDTH)];
    [self.flashButton centerVerticallyInView:self.bottomContainer];
    self.flashButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.flashButton.clipsToBounds = YES;
    [self.flashButton setImage:[UIImage imageNamed:@"temp-flash"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateHighlighted];
    [self.bottomContainer addSubview:self.flashButton];
    
}

-(void)configureToggleView{
    self.recordingModeToggleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - SIDE_PAD - ICON_WIDTH, self.previewBackgroundIV.frame.origin.y, ICON_WIDTH, self.previewBackgroundIV.frame.size.height)];
    self.recordingModeToggleView.userInteractionEnabled = YES;
    [self.bottomContainer addSubview:self.recordingModeToggleView];
    
    [self configureCameraButton];
    [self configureVideoButton];
    
}

-(void)configureCameraButton{
    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)];
    self.cameraIV.contentMode = UIViewContentModeScaleAspectFit;
    self.cameraIV.userInteractionEnabled = YES;
    self.cameraIV.image = [UIImage imageNamed:@"camera"];
    [self.recordingModeToggleView addSubview:self.cameraIV];
    
//    self.cameraIV.backgroundColor = [UIColor blackColor]; //For testing purposes
}

-(void)configureVideoButton{
    
    //The ending y coordinate of the thumbnail icon minus the height of the video icon
    NSInteger yOrigin = self.recordingModeToggleView.frame.size.height - ICON_WIDTH;
    
    self.videoIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOrigin, ICON_WIDTH, ICON_WIDTH)];
    self.videoIV.userInteractionEnabled = YES;
    self.videoIV.contentMode = UIViewContentModeScaleAspectFit;
    self.videoIV.image = [UIImage imageNamed:@"camera"];
    [self.recordingModeToggleView addSubview:self.videoIV];
    
//    self.videoIV.backgroundColor = [UIColor orangeColor]; //For testing purposes;
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
        
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    [self.previewButton removeObserver:self forKeyPath:@"highlighted" context:nil];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    if (self.locationManager.managerState == LocationManagerStateForeground)
        [self.locationManager stopUpdatingLocation];

    NSLog(@"did update locations in camera");
    
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
    
    [self.locationManager setupLocationMonitoringForState:LocationManagerStateBackground];
    
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
