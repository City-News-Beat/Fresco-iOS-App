//
//  FRSTrimTool.h
//  Fresco
//
//  Created by Philip Bernstein on 4/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
@protocol FRSTrimToolDelegate
@optional
-(void)trimmersDidAdjust;
@end
@interface FRSTrimTool : UIView
{
    
}

@property CMTime leftTime;
@property CMTime rightTime;
@property (nonatomic, assign) float right;
@property (nonatomic, assign) float left;
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, weak) id<FRSTrimToolDelegate> delegate;

-(void)setBackground:(UIView *)background;
@end
