//
//  FRSPlayer.h
//  Fresco
//
//  Created by Philip Bernstein on 4/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface FRSPlayer : AVPlayer
@property (weak, nonatomic) UIView *container;
@property BOOL wasMuted;
@end
