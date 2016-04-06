//
//  FRSTrimTool.m
//  Fresco
//
//  Created by Philip Bernstein on 4/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTrimTool.h"
#import "UIColor+Fresco.h"

@interface FRSTrimTool (defined)
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
@end

@implementation FRSTrimTool

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    [self setupUI];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self reconfigureUI];
}

-(void)reconfigureUI {
    
}

-(void)setupUI {
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.backgroundView];
    
    self.leftView = [[UIView alloc] init];
    self.rightView = [[UIView alloc] init];
    
    self.leftOutline = [[UIView alloc] init];
    self.rightOutline = [[UIView alloc] init];
    //
    self.rightOutline.backgroundColor = [UIColor frescoGreenColor];
    self.leftOutline.backgroundColor = [UIColor frescoGreenColor];
    
    [self.leftView addSubview:self.leftOutline];  // green thumb
    [self.rightView addSubview:self.rightOutline]; // green thumb
    
    [self reconfigureUI]; // set frames correctly
}

-(void)setBackground:(UIView *)background {
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = background;
    self.backgroundView.frame = CGRectMake(10, 8, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    [self addSubview:self.backgroundView];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.backgroundView.frame.size.width+20, self.backgroundView.frame.size.height+16); // resize to background
}

-(void)panRight:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.rightRect = self.rightView.frame;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
    
    [self handleRightChange]; // adjust cmtime
    
}

-(void)panLeft:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.leftRect = self.leftView.frame;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
    
    [self handleLeftChange]; // adjust cmtime
}

-(void)handleLeftChange {
    float currentLeftPosition = 0; // calculate relative x value for left thumb
    float currentRightPostion = 0; // calculate relative x value for right thumb
    
    self.left = currentLeftPosition / self.frame.size.width-20; // % calculated on bg frame
    self.right = currentRightPostion / self.frame.size.width-20; // % calculated on bg frame
    
    if (self.player) {
        float duration = CMTimeGetSeconds(self.player.currentItem.asset.duration);
        CMTime newStartTime = CMTimeMakeWithSeconds(duration * self.left, NSEC_PER_SEC);
        CMTime newEndTime = CMTimeMakeWithSeconds(duration * self.right, NSEC_PER_SEC);
        
        self.leftTime = newStartTime;
        self.rightTime = newEndTime;
    }
    
    if (self.delegate) {
        [self.delegate trimmersDidAdjust];
    }
}

-(void)handleRightChange {
    
    if (self.delegate) {
        [self.delegate trimmersDidAdjust];
    }
}

@end
