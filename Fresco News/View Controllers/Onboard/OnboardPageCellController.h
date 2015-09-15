//
//  FRSOnboardViewController.h
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnboardPageViewController.h"

@interface OnboardPageCellController : UIViewController

/*
** Index of Onboard View in page control
*/

@property (assign, nonatomic) NSInteger index;

// Onboard 1 assets
@property (strong, nonatomic) UIImageView *earth;
@property (strong, nonatomic) UIImageView *assignmentTopLeft;
@property (strong, nonatomic) UIImageView *assignmentBottomLeft;
@property (strong, nonatomic) UIImageView *assignmentTopRight;
@property (strong, nonatomic) UIImageView *assignmentBottomRight;

// Onboard 2 assets
@property (strong, nonatomic) UIImageView *cloud;
@property (strong, nonatomic) UIImageView *upload;
@property (strong, nonatomic) UIImageView *camera;

// Onboard 3 assets
@property (strong, nonatomic) UIImageView *greyCloud;
@property (strong, nonatomic) UIImageView *television;
@property (strong, nonatomic) UIImageView *newspaper;
@property (strong, nonatomic) UIImageView *uploadLeft;
@property (strong, nonatomic) UIImageView *uploadRight;
@property (strong, nonatomic) UIImageView *cash1;
@property (strong, nonatomic) UIImageView *cash2;
@property (strong, nonatomic) UIImageView *cash3;





- (void) onboardAnimation;


@end