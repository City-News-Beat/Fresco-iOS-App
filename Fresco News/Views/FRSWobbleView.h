//
//  FRSWobbleView.h
//  Fresco
//
//  Created by Philip Bernstein on 11/2/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface FRSWobbleView : UIView

@property (nonatomic, retain) UIImage *handImage;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *warningLabel;
@property (nonatomic, retain) UIView *backingView;

- (void)configureForWobble;

@end
