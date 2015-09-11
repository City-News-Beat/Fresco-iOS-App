//
//  FRSOnboardViewController.h
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardPageCellController : UIViewController

/*
** Index of Onboard View in page control
*/

@property (assign, nonatomic) NSInteger index;

// Onboard page one image views
@property (strong, nonatomic) IBOutlet UIImageView *onboard1EarthImageView;
@property (strong, nonatomic) IBOutlet UIImageView *onboard1AssignmentTopLeft;
@property (strong, nonatomic) IBOutlet UIImageView *onboard1AssignmentTopRight;
@property (strong, nonatomic) IBOutlet UIImageView *onboard1AssignmentBottomRight;
@property (strong, nonatomic) IBOutlet UIImageView *onboard1AssignmentBottomLeft;


// Onboard page two image views
@property (strong, nonatomic) IBOutlet UIImageView *onboard2Cloud;
@property (strong, nonatomic) IBOutlet UIImageView *onboard2Upload;
@property (strong, nonatomic) IBOutlet UIImageView *onboard2Camera;


// Onboard page three image views
@property (strong, nonatomic) IBOutlet UIImageView *onboard3GreyCloud;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3Television;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3Newspaper;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3Cash1;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3Cash2;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3Cash3;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3UploadRight;
@property (strong, nonatomic) IBOutlet UIImageView *onboard3UploadLeft;


@end
