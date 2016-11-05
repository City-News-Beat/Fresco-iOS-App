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
-(void)trimmingWillBegin;
-(void)trimmersDidAdjust;
-(void)trimmingDidEnd;
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
@property CGRect leftRect;
@property CGRect rightRect;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *leftView; // trim overlay
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *bottomView;

@property (nonatomic, retain) UIView *leftOutline;
@property (nonatomic, retain) UIView *rightOutline;

@property (nonatomic, retain) UIPanGestureRecognizer *leftPan;
@property (nonatomic, retain) UIPanGestureRecognizer *rightPan;

@property (nonatomic, retain) NSArray *leftSquares;
@property (nonatomic, retain) NSArray *rightSquares;
-(void)setBackground:(UIView *)background;
@end
