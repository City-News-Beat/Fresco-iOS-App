//
//  FRSOnboardViewController.m
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "OnboardPageCellController.h"

@interface OnboardPageCellController ()

/*
** Dictionary Values
*/

@property (nonatomic, strong) NSArray *mainHeaders;

@property (nonatomic, strong) NSArray *subHeaders;

@property (nonatomic, strong) NSArray *images;

/*
** UI Elements
*/

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *mainHeader;
@property (weak, nonatomic) IBOutlet UILabel *subHeader;
@property (weak, nonatomic) IBOutlet UIImageView *onboardImage;
@property (weak, nonatomic) IBOutlet UIImageView *progressImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomTextContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomLogo;

@property (strong, nonatomic) IBOutlet UIView *onboard1View;
@property (strong, nonatomic) IBOutlet UIView *onboard2View;
@property (strong, nonatomic) IBOutlet UIView *onboard3View;


@end

@implementation OnboardPageCellController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{

    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        
        // Create the data model
        self.mainHeaders = @[
                             MAIN_HEADER_1,
                             MAIN_HEADER_2,
                             MAIN_HEADER_3
                             ];
        
        self.subHeaders = @[
                            SUB_HEADER_1,
                            SUB_HEADER_2,
                            SUB_HEADER_3
                            ];
        
        self.images = @[
                            @"onboard1.png",
                            @"onboard2.png",
                            @"onboard3.png"
                            ];
        
    }
    
    return self;

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUpViews];
    [self setUpOnboard1];
    [self setUpOnboard2];
    [self setUpOnboard3];

    
    
    self.mainHeader.text = [self.mainHeaders objectAtIndex:self.index];
    
    self.subHeader.text = [self.subHeaders objectAtIndex:self.index];
    
    self.onboardImage.image = [UIImage imageNamed:[self.images objectAtIndex:self.index]];
    
    self.progressImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"progress-3-%li", (long)(self.index +1)]];
    
    //Show "Done" on the last view
    if(self.index == 2){
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
}

- (void) setUpViews {
        
    if (IS_STANDARD_IPHONE_6) {
        self.constraintBottomLogo.constant = 65;
        self.constraintBottomTextContainer.constant = 65;
        self.constraintBottomImage.constant = 85;
    }
    
    if (IS_ZOOMED_IPHONE_6 || IS_IPHONE_5) {
        self.constraintBottomLogo.constant = 30;
        self.constraintBottomTextContainer.constant = 40;
        self.constraintBottomImage.constant = 65;
    }
    
    if (IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6) {
        self.constraintBottomLogo.constant = 85;
        self.constraintBottomTextContainer.constant = 85;
        self.constraintBottomImage.constant = 105;
    }
    
}

- (void) setUpOnboard1 {
    
    // Create earth image view
    UIImageView *earth = [[UIImageView alloc] initWithFrame:CGRectMake(59, 47, 173, 173)];
    earth.image = [UIImage imageNamed:@"earth"];
    [earth setContentMode:UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:earth];
    
    // Create top left assignment image view
    UIImageView *assignmentTopLeft = [[UIImageView alloc] initWithFrame:CGRectMake(53, 51, 50, 50)];
    assignmentTopLeft.image = [UIImage imageNamed:@"assignment-left"];
    [assignmentTopLeft setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:assignmentTopLeft];
    
    // Create bottom left assignment image view
    UIImageView *assignmentBottomLeft = [[UIImageView alloc] initWithFrame:CGRectMake(92, 127, 50, 50)];
    assignmentBottomLeft.image = [UIImage imageNamed:@"assignment-left"];
    [assignmentBottomLeft setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:assignmentBottomLeft];
    
    // Create top right assignment image view with transform
    UIImageView *assignmentTopRight = [[UIImageView alloc] initWithFrame:CGRectMake(145, 22, 50, 50)];
    assignmentTopRight.image = [UIImage imageNamed:@"assignment-left"];
    [assignmentTopRight setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:assignmentTopRight];
    assignmentTopRight.transform = CGAffineTransformScale(assignmentTopRight.transform, 1.0 , 1.0);
    assignmentTopRight.transform = CGAffineTransformScale(assignmentTopRight.transform, -1.0 , 1.0);
    
    // Create bottom right assignment image view with transform
    UIImageView *assignmentBottomRight = [[UIImageView alloc] initWithFrame:CGRectMake(179, 140, 50, 50)];
    assignmentBottomRight.image = [UIImage imageNamed:@"assignment-left"];
    [assignmentBottomRight setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:assignmentBottomRight];
    assignmentBottomRight.transform = CGAffineTransformScale(assignmentBottomLeft.transform, 1.0 , -1.0);
    assignmentBottomRight.transform = CGAffineTransformScale(assignmentBottomLeft.transform, -1.0 , 1.0);
    
    // Init images with alpha of 0
    earth.alpha = 0;
    assignmentTopLeft.alpha = 0;
    assignmentBottomLeft.alpha = 0;
    assignmentTopRight.alpha = 0;
    assignmentBottomRight.alpha = 0;

}

- (void) setUpOnboard2 {
    
    // Create cloud image view
    UIImageView *cloud = [[UIImageView alloc] initWithFrame:CGRectMake(81, 33, 122, 80)];
    cloud.image = [UIImage imageNamed:@"cloud"];
    [cloud setContentMode: UIViewContentModeScaleToFill];
    [self.onboard2View addSubview:cloud];
    
    // Create upload image view
    UIImageView *upload = [[UIImageView alloc] initWithFrame:CGRectMake(130, 130, 24, 24)];
    upload.image = [UIImage imageNamed:@"upload"];
    [upload setContentMode: UIViewContentModeScaleToFill];
    [self.onboard2View addSubview:upload];
    
    // Create camera image view
    UIImageView *camera = [[UIImageView alloc] initWithFrame:CGRectMake(109, 173, 66, 60)];
    camera.image = [UIImage imageNamed:@"camera"];
    [camera setContentMode: UIViewContentModeScaleToFill];
    [self.onboard2View addSubview:camera];
    
    // Init images with alpha of 0
    cloud.alpha = 0;
    upload.alpha = 0;
    camera.alpha = 0;
    
}

- (void) setUpOnboard3 {
    
    // Create cloud image view
    UIImageView *cloud = [[UIImageView alloc] initWithFrame:CGRectMake(85, 37, 115, 78)];
    cloud.image = [UIImage imageNamed:@"grey-cloud"];
    [cloud setContentMode: UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:cloud];

    // Create television image view
    UIImageView *television = [[UIImageView alloc] initWithFrame:CGRectMake(48, 173, 72, 60)];
    television.image = [UIImage imageNamed:@"television"];
    [cloud setContentMode: UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:television];
    
    // Create newspaper image view
    UIImageView *newspaper = [[UIImageView alloc] initWithFrame:CGRectMake(165, 173, 68, 60)];
    newspaper.image = [UIImage imageNamed:@"newspaper"];
    [newspaper setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:newspaper];
    
    // Create upload left image view
    UIImageView *uploadLeft = [[UIImageView alloc] initWithFrame:CGRectMake(165, 135, 24, 24)];
    uploadLeft.image = [UIImage imageNamed:@"upload"];
    [uploadLeft setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:uploadLeft];
    uploadLeft.transform = CGAffineTransformMakeRotation(M_PI_2 + 1);

    // Create upload right image view
    UIImageView *uploadRight = [[UIImageView alloc] initWithFrame:CGRectMake(95, 135, 24, 24)];
    uploadRight.image = [UIImage imageNamed:@"upload"];
    [uploadRight setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:uploadRight];
    uploadRight.transform = CGAffineTransformMakeRotation(M_PI_2 - 1);

    // Create cash1 image view
    UIImageView *cash1 = [[UIImageView alloc] initWithFrame:CGRectMake(205, 36, 35, 24)];
    cash1.image = [UIImage imageNamed:@"cash"];
    [cash1 setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:cash1];
    cash1.transform = CGAffineTransformMakeRotation(.13);

    // Create cash2 image view
    UIImageView *cash2 = [[UIImageView alloc] initWithFrame:CGRectMake(25, 60, 35, 24)];
    cash2.image = [UIImage imageNamed:@"cash"];
    [cash2 setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:cash2];
    cash2.transform = CGAffineTransformMakeRotation(-.785);

    // Create cash3 image view
    UIImageView *cash3 = [[UIImageView alloc] initWithFrame:CGRectMake(228, 114, 35, 24)];
    cash3.image = [UIImage imageNamed:@"cash"];
    [cash3 setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:cash3];
    cash3.transform = CGAffineTransformMakeRotation(.785);

}















































@end
