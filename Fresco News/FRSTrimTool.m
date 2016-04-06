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
    float effectiveWidth = self.frame.size.width-30;
    
    self.leftOutline.frame = CGRectMake(30 + (effectiveWidth * self.left), 10, 15, self.frame.size.height-20);
    self.rightOutline.frame = CGRectMake(self.frame.size.width-15 - 30 - (effectiveWidth * self.right), 10, 15, self.frame.size.height-20);
    
    self.topView.frame = CGRectMake(35, 10, self.frame.size.width-70, 6);
    self.bottomView.frame = CGRectMake(35, self.frame.size.height-16, self.frame.size.width-70, 6);
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
    [self drawSquares];
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor frescoGreenColor];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor frescoGreenColor];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.rightView];
    [self addSubview:self.leftView];
    
    self.leftOutline.layer.masksToBounds = YES;
    self.rightOutline.layer.masksToBounds = YES;
    
    self.leftOutline.layer.cornerRadius = 2.0;
    self.rightOutline.layer.cornerRadius = 2.0;
    
    [self reconfigureUI]; // set frames correctly
}

-(void)drawSquares {
    NSMutableArray *la = [[NSMutableArray alloc] init]; // left array
    NSMutableArray *ra = [[NSMutableArray alloc] init]; // right array
    NSMutableArray *ca; // currently represented array
    UIView *cv; // current represented view (leftOutline v rightOutline)
    
    for (int r = 0; r < 2; r++) {
        
        if (r == 0) {
            ca = la;
            cv = self.leftOutline;
        }
        else {
            ca = ra;
            cv = self.rightOutline;
        }
        
        for (int i = 0; i < 3; i++) {
            for (int c = 0; c < 2; c++) {
                float x = 4 * c + 5; // 0 | 4
                float y = 4 * i + 1;
                UIView *currentSquare = [[UIView alloc] initWithFrame:CGRectMake(x, y, 2, 2)];
                currentSquare.backgroundColor = [UIColor whiteColor];
                [cv addSubview:currentSquare];
                [ca addObject:currentSquare];
            }
        }
        
        if (r == 0) {
            self.leftSquares = ca;
        }
        else {
            self.rightSquares = ca;
        }
    }
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
    [self handleLeftChange];
}

@end
