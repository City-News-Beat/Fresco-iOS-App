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
    UIImageView *earth =[[UIImageView alloc] initWithFrame:CGRectMake(59,47,173,173)];
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
 
}

- (void) setUpOnboard2 {
    
    
    
}

- (void) setUpOnboard3 {
    
}














































@end
