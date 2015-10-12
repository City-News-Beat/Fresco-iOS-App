//
//  FRSOnboardViewController.h
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnboardPageViewController.h"

typedef enum : NSUInteger {
    AnimationStateOne,
    AnimationStateTwo,
    AnimationStateThree,
    AnimationStateThreee,
    AnimationStateThreeee,
    AnimationStateThreeeee,
    AnimationStateThreeeeee,
    AnimationStateThreeeeeee,
    AnimationStateThreeeeeeee
} AnimationState;


@interface OnboardPageCellController : UIViewController

/*
 ** Custom initializer for animation state property
 */

-(id)initWithAnimationState:(AnimationState)state;

/*
 ** Current animation state
 */

@property (assign, nonatomic) AnimationState animationState;

/*
 ** Onboard Assets
 */

// Page 1
@property (strong, nonatomic) UIImageView *earth;
@property (strong, nonatomic) UIImageView *assignmentTopLeft;
@property (strong, nonatomic) UIImageView *assignmentBottomLeft;
@property (strong, nonatomic) UIImageView *assignmentTopRight;
@property (strong, nonatomic) UIImageView *assignmentBottomRight;

// Page 2
@property (strong, nonatomic) UIImageView *cloud;
@property (strong, nonatomic) UIImageView *upload;
@property (strong, nonatomic) UIImageView *camera;

// Page 3
@property (strong, nonatomic) UIImageView *greyCloud;
@property (strong, nonatomic) UIImageView *television;
@property (strong, nonatomic) UIImageView *newspaper;
@property (strong, nonatomic) UIImageView *uploadLeft;
@property (strong, nonatomic) UIImageView *uploadRight;
@property (strong, nonatomic) UIImageView *cash1;
@property (strong, nonatomic) UIImageView *cash2;
@property (strong, nonatomic) UIImageView *cash3;


- (void)performAnimation;

@end