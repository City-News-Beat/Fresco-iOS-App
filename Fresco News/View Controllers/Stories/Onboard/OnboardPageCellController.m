//
//  FRSOnboardViewController.m
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "OnboardPageCellController.h"
#import "OnboardPageViewController.h"
#import "UIImageView+Additions.h"

@interface OnboardPageCellController ()

@property (strong, nonatomic) OnboardPageViewController *pagedViewController;

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

-(id)initWithAnimationState:(AnimationState)state{

    self = [super init];
    
    if(self){
    
        self.animationState = state;
    
    }
    
    return self;

}

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
    
    if(self.animationState == AnimationStateOne)
        [self setUpOnboard1];
    else if(self.animationState == AnimationStateTwo)
        [self setUpOnboard2];
    else if(self.animationState == AnimationStateThree)
        [self setUpOnboard3];

    /** Always run */
    
    self.mainHeader.text = [self.mainHeaders objectAtIndex:self.animationState];
    
    self.subHeader.text = [self.subHeaders objectAtIndex:self.animationState];
    
    self.onboardImage.image = [UIImage imageNamed:[self.images objectAtIndex:self.animationState]];
    
    self.progressImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"progress-3-%li", (long)(self.animationState +1)]];
    
    /** **/
    
    //Show "Done" on the last view
    if(self.animationState == 2){
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
}



- (void)setUpOnboard1 {
    
    self.earth = [UIImageView UIImageViewWithName:@"earth"
                                         andFrame:CGRectMake(59, 47, 173, 173)
                                   andContentMode: UIViewContentModeScaleToFill ];
    
    self.earth.transform = CGAffineTransformMakeRotation(M_PI_2 - 1);
    
    
    [self.onboard1View addSubview:self.earth];

    
//    // Create earth image view
//    self.earth = [[UIImageView alloc] initWithFrame:CGRectMake(59, 47, 173, 173)];
//    self.earth.image = [UIImage imageNamed:@"earth"];
//    [self.earth setContentMode:UIViewContentModeScaleToFill];
//    [self.onboard1View addSubview:self.earth];
    
    // Create top left assignment image view
    self.assignmentTopLeft = [[UIImageView alloc] initWithFrame:CGRectMake(73, 71, 50, 50)];
    self.assignmentTopLeft.image = [UIImage imageNamed:@"assignment-left"];
    self.assignmentTopLeft.layer.anchorPoint = CGPointMake(1, 1);
    [self.assignmentTopLeft setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:self.assignmentTopLeft];
    
    // Create bottom left assignment image view
    self.assignmentBottomLeft = [[UIImageView alloc] initWithFrame:CGRectMake(102, 147, 50, 50)];
    self.assignmentBottomLeft.image = [UIImage imageNamed:@"assignment-left"];
    self.assignmentBottomLeft.layer.anchorPoint = CGPointMake(1, 1);
    [self.assignmentBottomLeft setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:self.assignmentBottomLeft];
    
    
    // Create top right assignment image view with transform
    self.assignmentTopRight = [[UIImageView alloc] initWithFrame:CGRectMake(135, 50, 50, 50)];
    self.assignmentTopRight.image = [UIImage imageNamed:@"assignment-right"];
    self.assignmentTopRight.layer.anchorPoint = CGPointMake(-.01, 1);
    [self.assignmentTopRight setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:self.assignmentTopRight];

    
    // Create bottom right assignment image view with transform
    self.assignmentBottomRight = [[UIImageView alloc] initWithFrame:CGRectMake(165, 160, 50, 50)];
    self.assignmentBottomRight.image = [UIImage imageNamed:@"assignment-right"];
    self.assignmentBottomRight.layer.anchorPoint = CGPointMake(-.01, 1);
    [self.assignmentBottomRight setContentMode: UIViewContentModeScaleToFill];
    [self.onboard1View addSubview:self.assignmentBottomRight];
    
    // Init images with alpha of 0
    self.earth.alpha = 0;
    self.assignmentTopLeft.alpha = 0;
    self.assignmentBottomLeft.alpha = 0;
    self.assignmentTopRight.alpha = 0;
    self.assignmentBottomRight.alpha = 0;

}

- (void) setUpOnboard2 {
    
    // Create cloud image view
    self.cloud = [[UIImageView alloc] initWithFrame:CGRectMake(81, 33, 122, 80)];
    self.cloud.image = [UIImage imageNamed:@"cloud"];
    [self.cloud setContentMode: UIViewContentModeScaleToFill];
    [self.onboard2View addSubview:self.cloud];
    
    // Create upload image view
    self.upload = [[UIImageView alloc] initWithFrame:CGRectMake(130, 130, 24, 24)];
    self.upload.image = [UIImage imageNamed:@"upload"];
    [self.upload setContentMode: UIViewContentModeScaleToFill];
    [self.onboard2View addSubview:self.upload];
    
    // Create camera image view
    self.camera = [[UIImageView alloc] initWithFrame:CGRectMake(109, 173, 66, 60)];
    self.camera.image = [UIImage imageNamed:@"camera"];
    [self.camera setContentMode: UIViewContentModeScaleToFill];
    [self.onboard2View addSubview:self.camera];
    
    // Init images with alpha of 0
    self.cloud.alpha = 0;
    self.upload.alpha = 0;
    self.camera.alpha = 0;
    
}

- (void)setUpOnboard3 {
    
    
//    // Create television image view
//    self.television = [UIImageView UIImageViewWithName:@"television"
//                       andFrame:CGRectMake(48, 173, 72, 60)
//                       andContentMode:UIViewContentModeScaleToFill];
//    
//    [self.onboard3View addSubview:self.television];
//    
//    
//    // Create newspaper image view
//    self.newspaper = [UIImageView UIImageViewWithName:@"newspaper" andFrame:CGRectMake(165, 173, 68, 60) andContentMode:UIViewContentModeScaleToFill andTransform:nil];
//    
//    [self.onboard3View addSubview:self.newspaper];
    
    
    // Create upload left image view
    self.uploadLeft = [[UIImageView alloc] initWithFrame:CGRectMake(165, 135, 24, 24)];
    self.uploadLeft.image = [UIImage imageNamed:@"upload"];
    [self.uploadLeft setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:self.uploadLeft];
    self.uploadLeft.transform = CGAffineTransformMakeRotation(M_PI_2 + 1);

    // Create upload right image view
    self.uploadRight = [[UIImageView alloc] initWithFrame:CGRectMake(95, 135, 24, 24)];
    self.uploadRight.image = [UIImage imageNamed:@"upload"];
    [self.uploadRight setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:self.uploadRight];
    self.uploadRight.transform = CGAffineTransformMakeRotation(M_PI_2 - 1);

    // Create cash1 image view
    self.cash1 = [[UIImageView alloc] initWithFrame:CGRectMake(205, 36, 35, 24)];
    self.cash1.image = [UIImage imageNamed:@"cash"];
    [self.cash1 setContentMode:UIViewContentModeScaleToFill];
    self.cash1.transform = CGAffineTransformMakeRotation(.13);
    [self.onboard3View addSubview:self.cash1];
    
    // Create cash2 image view
    self.cash2 = [[UIImageView alloc] initWithFrame:CGRectMake(70, 60, 35, 24)];
    self.cash2.image = [UIImage imageNamed:@"cash"];
    [self.cash2 setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:self.cash2];
    self.cash2.transform = CGAffineTransformMakeRotation(-.785);

    // Create cash3 image view
    self.cash3 = [[UIImageView alloc] initWithFrame:CGRectMake(228, 114, 35, 24)];
    self.cash3.image = [UIImage imageNamed:@"cash"];
    [self.cash3 setContentMode:UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:self.cash3];
    self.cash3.transform = CGAffineTransformMakeRotation(.785);
    
    // Create cloud image view
    self.greyCloud = [[UIImageView alloc] initWithFrame:CGRectMake(85, 37, 115, 78)];
    self.greyCloud.image = [UIImage imageNamed:@"grey-cloud"];
    [self.greyCloud setContentMode: UIViewContentModeScaleToFill];
    [self.onboard3View addSubview:self.greyCloud];
    
    self.greyCloud.alpha = 0;
    self.television.alpha = 0;
    self.newspaper.alpha = 0;
    self.uploadLeft.alpha = 0;
    self.uploadRight.alpha = 0;
    self.cash1.alpha = 0;
    self.cash2.alpha = 0;
    self.cash3.alpha = 0;
        
}

//+ (UIImageView *)createUIImageViewWithName:(NSString *)imageName andFrame:(CGRect)frame andContentMode:(UIViewContentMode)contentMode andTransform:(CGAffineTransform *)transform{
//
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
//    imageView.image = [UIImage imageNamed:imageName];
//    imageView.contentMode = contentMode;
//    imageView.transform = *(transform);
//    
//    return imageView;
//
//
//}
//
//+ (UIImageView *)createUIImageViewWithName:(NSString *)imageName andFrame:(CGRect)frame andContentMode:(UIViewContentMode)contentMode{
//
//   return [self createUIImageViewWithName:imageName andFrame:frame andContentMode:contentMode andTransform:nil];
//
//}

- (void)setUpViews {
    
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

@end
