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
#import "CameraPreviewView.h"

//Managers
#import "FRSLocationManager.h"
#import "FRSDataManager.h"
#import "FRSGalleryAssetsManager.h"

//Categories
#import "UIColor+Additions.h"

#import "UIView+Helpers.h"
#import "FRSRoundedView.h"


#define ICON_WIDTH 24
#define PREVIEW_WIDTH 56
#define APERTURE_WIDTH 72
#define SIDE_PAD 12
#define PHOTO_FRAME_RATIO 4/3


@interface FRSCameraViewController ()

@property (strong, nonatomic) CameraPreviewView *preview;

@property (strong, nonatomic) UIView *bottomContainer;

@property (strong, nonatomic) UIButton *apertureButton;
@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIImageView *previewBackgroundIV;

//@property (strong, nonatomic) FRSRoundedView *previewView;

@property (strong, nonatomic) UIView *recordingModeToggleView;
@property (strong, nonatomic) UIImageView *cameraIV;
@property (strong, nonatomic) UIImageView *videoIV;

@property (strong, nonatomic) UIButton *flashButton;

@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) UIView *whiteView;

@end

@implementation FRSCameraViewController

-(instancetype)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self configureUI];
    // Do any additional setup after loading the view.
}

#pragma mark - UI configuration methods

-(void)configureUI{
    [self configurePreview];
    [self configureBottomContainer];
}

-(void)configurePreview{
    
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
    [self.bottomContainer addSubview:self.previewBackgroundIV];
    [self.previewBackgroundIV addDropShadowWithColor:[UIColor frescoDropShadowColor] path:nil];
    
    
    self.previewButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, PREVIEW_WIDTH - 8, PREVIEW_WIDTH - 8)];
    self.previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.previewButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.previewButton setBackgroundImage:[UIImage imageNamed:@"twitter-b"] forState:UIControlStateNormal];
    [self.previewButton setBackgroundImage:[UIImage imageNamed:@"twitter-b"] forState:UIControlStateHighlighted];
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
        
        NSLog(@"change = %@", change);
        
        NSNumber *new = [change objectForKey:@"new"];
        NSNumber *old = [change objectForKey:@"old"];
        
        if ([new isEqualToNumber:@1] && [old isEqualToNumber:@0]){ //Was unhighlighted and then became highlighted
            self.whiteView.alpha = 0.3;
        }
        else if ([new isEqualToNumber:@0] && [old isEqualToNumber:@1]){ // Was highlighted and now unhighlighted
            self.whiteView.alpha = 0.0;
        }
        else if ([new isEqualToNumber:@1] && [old isEqualToNumber:@1]){ //Was highlighted and is staying highlighted
            self.whiteView.alpha = 0.3;
        }
        else {
            self.whiteView.alpha = 0.0;
        }

    }
}

-(void)configureApertureButton{
    self.apertureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, APERTURE_WIDTH, APERTURE_WIDTH)];
    [self.apertureButton centerVerticallyInView:self.bottomContainer];
    [self.apertureButton centerHorizontallyInView:self.bottomContainer];
    
    self.apertureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.apertureButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [self.apertureButton setImage:[UIImage imageNamed:@"video-recording-icon"] forState:UIControlStateHighlighted];
    
    [self.apertureButton addDropShadowWithColor:[UIColor frescoDropShadowColor] path:nil];

    [self.bottomContainer addSubview:self.apertureButton];
    
//    self.apertureButton.backgroundColor = [UIColor blueColor]; //For testing purposes
}

-(void)configureFlashButton{
    
    
    // We start at the edge of the aperture button and then center the view between the aperture button and the recordModeToggleView
    NSInteger apertureEdge = self.apertureButton.frame.origin.x + self.apertureButton.frame.size.width;
    NSInteger xOrigin = apertureEdge + (self.view.frame.size.width - apertureEdge - SIDE_PAD - (ICON_WIDTH * 2))/2;
    
    
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin, 0, ICON_WIDTH, ICON_WIDTH)];
    [self.flashButton centerVerticallyInView:self.bottomContainer];
    self.flashButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.flashButton.clipsToBounds = YES;
    [self.flashButton setImage:[UIImage imageNamed:@"temp-flash"] forState:UIControlStateNormal];
    [self.bottomContainer addSubview:self.flashButton];

    
//    self.flashIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, ICON_WIDTH, ICON_WIDTH)];
//    [self.flashIV centerVerticallyInView:self.bottomContainer];
//    self.flashIV.contentMode = UIViewContentModeScaleAspectFit;
//    self.flashIV.userInteractionEnabled = YES;
//    self.flashIV.image = [UIImage imageNamed:@"flash-on"];
//    
//    [self.bottomContainer addSubview:self.flashIV];
    
//    self.flashIV.backgroundColor = [UIColor greenColor]; //For testing purposes
    
}

-(void)configureToggleView{
    self.recordingModeToggleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - SIDE_PAD - ICON_WIDTH, self.previewButton.frame.origin.y, ICON_WIDTH, self.previewButton.frame.size.height)];
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
