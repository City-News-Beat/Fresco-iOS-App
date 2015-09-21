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
    
    /** Create earth image view */
    self.earth = [UIImageView UIImageViewWithName:@"earth"
                                         andFrame:CGRectMake(59, 47, 173, 173)
                                   andContentMode: UIViewContentModeScaleToFill ];
    
    [self.onboard1View addSubview:self.earth];
    
    
    
    /** Create top left assignment image view */
    self.assignmentTopLeft = [UIImageView UIImageViewWithName:@"assignment-left"
                                                     andFrame:CGRectMake(73, 71, 50, 50)
                                               andContentMode:UIViewContentModeScaleToFill];
    
    self.assignmentTopLeft.layer.anchorPoint = CGPointMake(1, 1);
    
    [self.onboard1View addSubview:self.assignmentTopLeft];

    
    
    /** Create bottom left assignment image view */
    self.assignmentBottomLeft = [UIImageView UIImageViewWithName:@"assignment-left"
                                                        andFrame:CGRectMake(102, 147, 50, 50)
                                                  andContentMode:UIViewContentModeScaleToFill];
    
    self.assignmentBottomLeft.layer.anchorPoint = CGPointMake(1, 1);
    
    [self.onboard1View addSubview:self.assignmentBottomLeft];


    
    /** Create bottom left assignment image view */
    self.assignmentTopRight = [UIImageView UIImageViewWithName:@"assignment-right"
                                                        andFrame:CGRectMake(135, 50, 50, 50)
                                                  andContentMode:UIViewContentModeScaleToFill];
    
    self.assignmentTopRight.layer.anchorPoint = CGPointMake(-.01, 1);
    
    [self.onboard1View addSubview:self.assignmentTopRight];
    
    
    
    /** Create bottom right assignment image view */
    self.assignmentBottomRight = [UIImageView UIImageViewWithName:@"assignment-right"
                                                      andFrame:CGRectMake(165, 160, 50, 50)
                                                andContentMode:UIViewContentModeScaleToFill];
    
    self.assignmentBottomRight.layer.anchorPoint = CGPointMake(-.01, 1);
    
    [self.onboard1View addSubview:self.assignmentBottomRight];
    
    
    
    // Init images with alpha of 0
    self.earth.alpha = 1;
    self.assignmentTopLeft.alpha = 0;
    self.assignmentBottomLeft.alpha = 0;
    self.assignmentTopRight.alpha = 0;
    self.assignmentBottomRight.alpha = 0;

}

- (void) setUpOnboard2 {
    
    
    /** Create cloud image view */
    self.cloud = [UIImageView UIImageViewWithName:@"cloud"
                                         andFrame:CGRectMake(81, 33, 122, 80)
                                   andContentMode: UIViewContentModeScaleToFill ];
    
    [self.onboard1View addSubview:self.cloud];
    

    
    /** Create cloud image view */
    self.upload = [UIImageView UIImageViewWithName:@"upload"
                                         andFrame:CGRectMake(130, 130, 24, 24)
                                   andContentMode: UIViewContentModeScaleToFill ];
    
    [self.onboard1View addSubview:self.upload];
    
    

    /** Create camera image view */
    self.camera = [UIImageView UIImageViewWithName:@"camera"
                                          andFrame:CGRectMake(109, 173, 66, 60)
                                    andContentMode: UIViewContentModeScaleToFill ];
    
    [self.onboard1View addSubview:self.camera];
    
    
    // Init images with alpha of 0
    self.cloud.alpha = 1;
    self.upload.alpha = 1;
    self.camera.alpha = 1;
    
    self.assignmentTopRight.alpha = 0;
    self.assignmentTopLeft.alpha = 0;
    self.assignmentBottomRight.alpha = 0;
    self.assignmentBottomLeft.alpha = 0;
    
}

- (void)setUpOnboard3 {
    
    
    /** Create television image view */
    self.television = [UIImageView UIImageViewWithName:@"television"
                       andFrame:CGRectMake(48, 173, 72, 60)
                       andContentMode:UIViewContentModeScaleToFill];
    
    [self.onboard3View addSubview:self.television];
    
    
    
    /** Create camera image view */
    self.newspaper = [UIImageView UIImageViewWithName:@"newspaper"
                                              andFrame:CGRectMake(165, 173, 68, 60)
                                        andContentMode:UIViewContentModeScaleToFill];
    
    [self.onboard3View addSubview:self.newspaper];
    
    
    
    /** Create upload left image view */
    self.uploadLeft = [UIImageView UIImageViewWithName:@"upload"
                                             andFrame:CGRectMake(165, 135, 24, 24)
                                       andContentMode:UIViewContentModeScaleToFill];
    
    self.uploadLeft.transform = CGAffineTransformMakeRotation(M_PI_2 + 1);
    [self.onboard3View addSubview:self.uploadLeft];
    
    
    
    /** Create upload right image view */
    self.uploadRight = [UIImageView UIImageViewWithName:@"upload"
                                              andFrame:CGRectMake(95, 135, 24, 24)
                                        andContentMode:UIViewContentModeScaleToFill];
    
    self.uploadRight.transform = CGAffineTransformMakeRotation(M_PI_2 - 1);
    [self.onboard3View addSubview:self.uploadRight];
    
    
    /** Create cash1 image view */
    self.cash1 = [UIImageView UIImageViewWithName:@"cash"
                                               andFrame:CGRectMake(205, 36, 35, 24)
                                         andContentMode:UIViewContentModeScaleToFill];
    
    self.cash1.transform = CGAffineTransformMakeRotation(.13);
    [self.onboard3View addSubview:self.cash1];
    

    /** Create cash2 image view */
    self.cash2 = [UIImageView UIImageViewWithName:@"cash"
                                         andFrame:CGRectMake(45, 60, 35, 24)
                                   andContentMode:UIViewContentModeScaleToFill];
    
    self.cash2.transform = CGAffineTransformMakeRotation(-.785);
    [self.onboard3View addSubview:self.cash2];
    

    /** Create cash3 image view */
    self.cash3 = [UIImageView UIImageViewWithName:@"cash"
                                         andFrame:CGRectMake(228, 114, 35, 24)
                                   andContentMode:UIViewContentModeScaleToFill];
    
    self.cash3.transform = CGAffineTransformMakeRotation(.785);
    [self.onboard3View addSubview:self.cash3];
    
    
    /** Create grey cloud image view */
    self.greyCloud = [UIImageView UIImageViewWithName:@"grey-cloud"
                                         andFrame:CGRectMake(85, 37, 115, 78)
                                   andContentMode:UIViewContentModeScaleToFill];
    
    [self.onboard3View addSubview:self.greyCloud];

    self.greyCloud.alpha = 1;
    self.television.alpha = 1;
    self.newspaper.alpha = 1;
    self.uploadLeft.alpha = 1;
    self.uploadRight.alpha = 1;
    self.cash1.alpha = 0;
    self.cash2.alpha = 0;
    self.cash3.alpha = 0;
    



    
}

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
