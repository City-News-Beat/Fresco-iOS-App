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

#import "UIImageView+Additions.h"


@interface FRSCameraViewController ()

@property (strong, nonatomic) CameraPreviewView *preview;

@property (strong, nonatomic) UIView *bottomContainer;

@property (strong, nonatomic) UIImageView *apertureIV;
@property (strong, nonatomic) UIImageView *thumbnailIV;
@property (strong, nonatomic) UIView *recordingModeToggleView;
@property (strong, nonatomic) UIImageView *cameraIV;
@property (strong, nonatomic) UIImageView *videoIV;
@property (strong, nonatomic) UIImageView *flashIV;

@property (strong, nonatomic) UIButton *nextButton;

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

-(void)configureUI{
    [self configurePreview];
    [self configureBottomContainer];
}

-(void)configurePreview{
    
}

-(void)configureBottomContainer{
    
    self.bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 4/3, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * 4/3))];
    self.bottomContainer.backgroundColor = [UIColor frescoDefaultBackgroundColor];
    [self.view addSubview:self.bottomContainer];
    
    [self configureNextSection];
    [self configureApertureButton];
    [self configureFlashButton];
    [self configureToggleView];
}

-(void)configureNextSection{
    self.thumbnailIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
    [self.thumbnailIV centerVerticallyInView:self.bottomContainer];
    self.thumbnailIV.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailIV.clipsToBounds = YES;
    [self.thumbnailIV addBorderWithWidth:4.0 color:[UIColor whiteColor]];
    [self.bottomContainer addSubview:self.thumbnailIV];
    
    self.thumbnailIV.backgroundColor = [UIColor redColor]; //For testing purposes
}

-(void)configureApertureButton{
    self.apertureIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    [self.apertureIV centerVerticallyInView:self.bottomContainer];
    [self.apertureIV centerHorizontallyInView:self.bottomContainer];
    self.apertureIV.contentMode = UIViewContentModeScaleAspectFit;
    self.apertureIV.clipsToBounds = YES;
    [self.bottomContainer addSubview:self.apertureIV];
    
    self.apertureIV.backgroundColor = [UIColor blueColor]; //For testing purposes
}

-(void)configureFlashButton{
    
    NSInteger xOrigin = self.view.frame.size.width/2 + (self.view.frame.size.width/2 - 14 - 18 - 24)/2;
    
    self.flashIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 24, 24)];
    [self.flashIV centerVerticallyInView:self.bottomContainer];
    self.flashIV.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.bottomContainer addSubview:self.flashIV];
    
    self.flashIV.backgroundColor = [UIColor greenColor]; //For testing purposes
    
}

-(void)configureToggleView{
    self.recordingModeToggleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 14 - 25, self.thumbnailIV.frame.origin.y, 25, self.thumbnailIV.frame.origin.y)];
    
}

-(void)configureCameraButton{
    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 14 - 25, self.thumbnailIV.frame.origin.y, 25, 18)];
    self.cameraIV.contentMode = UIViewContentModeScaleAspectFit;
    [self.bottomContainer addSubview:self.cameraIV];
    
    self.cameraIV.backgroundColor = [UIColor blackColor]; //For testing purposes
}

-(void)configureVideoButton{
    
    //The ending y coordinate of the thumbnail icon minus the height of the video icon
    NSInteger yOrigin = (self.thumbnailIV.frame.origin.y + self.thumbnailIV.frame.size.height) - 18;
    
    self.videoIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.cameraIV.frame.origin.x, yOrigin, 25, 18)];
    [self.bottomContainer addSubview:self.videoIV];
    
    self.videoIV.backgroundColor = [UIColor orangeColor]; //For testing purposes;
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
