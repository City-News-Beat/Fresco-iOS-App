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

-(void)setupGestureRecognizers {
    
    if (self.leftView.gestureRecognizers.count > 0) {
        return;
    }
    
    UIPanGestureRecognizer *leftRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeft:)];
    UIPanGestureRecognizer *rightRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRight:)];
    
    [self.leftView addGestureRecognizer:leftRecognizer];
    [self.rightView addGestureRecognizer:rightRecognizer];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self reconfigureUI];
}

-(void)reconfigureUI {
    float effectiveWidth = self.frame.size.width-30;
    
    self.leftView.frame = CGRectMake(0, 0, 30 + (effectiveWidth * self.left) + 15, self.frame.size.height);
    self.rightView.frame = CGRectMake(self.frame.size.width-15 - 30 - (effectiveWidth * self.right), 0, self.leftView.frame.size.width, self.frame.size.height);
    
    self.leftOutline.frame = CGRectMake(30 + (effectiveWidth * self.left), 10, 15, self.frame.size.height-20);
    self.rightOutline.frame = CGRectMake(0, 10, 15, self.frame.size.height-20);
    
    self.topView.frame = CGRectMake(35, 10, self.frame.size.width-70, 4);
    self.bottomView.frame = CGRectMake(35, self.frame.size.height-14, self.frame.size.width-70, 4);
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
    [self setupGestureRecognizers];
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
        
        for (int i = 0; i < 4; i++) {
            for (int c = 0; c < 2; c++) {
                float x = 4 * c + 5; // 0 | 4
                float y = 4 * i + 1 + 7 + ((self.frame.size.height - 50) / 2);
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
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.backgroundView.frame.size.width+60, self.backgroundView.frame.size.height+16); // resize to background
}

-(void)panRight:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.rightRect = self.rightView.frame;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self];
        
        float xOffset = translation.x;
        float newX = self.rightRect.origin.x + xOffset;
        
        CGRect newFrame = CGRectMake(newX, self.rightRect.origin.y, self.rightRect.size.width, self.rightRect.size.height);
        
        
        self.rightView.frame = [self checkRight:newFrame];
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
        CGPoint translation = [sender translationInView:self];
        
        float xOffset = translation.x;
        float newX = self.leftRect.origin.x + xOffset;
        
        CGRect newFrame = CGRectMake(newX, self.leftRect.origin.y, self.leftRect.size.width, self.leftRect.size.height);
    
        
        self.leftView.frame = [self checkLeft:newFrame];
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
    
    [self handleLeftChange]; // adjust cmtime
}

-(CGRect)checkLeft:(CGRect)left {
    float x = left.origin.x;
    if (x > self.rightView.frame.origin.x - 45) {
        left.origin.x = self.rightView.frame.origin.x - 45;
    }
    if (x < 0) {
        left.origin.x = 0;
    }
    
    float yDiff = self.frame.size.width -self.rightView.frame.origin.x;
    float xBorder = 30 + left.origin.x;
    float width = self.frame.size.width - xBorder - yDiff;
    
    self.topView.frame = CGRectMake(xBorder+5, self.topView.frame.origin.y, width, self.topView.frame.size.height);
     self.bottomView.frame = CGRectMake(xBorder+5, self.bottomView.frame.origin.y, width, self.bottomView.frame.size.height);
    
    x = left.origin.x;
    float w = self.frame.size.width-60-30;
    self.left = x / w;
    
    NSLog(@"LEFT: %f", self.left);

    return left;
}

-(CGRect)checkRight:(CGRect)right {
    float x = right.origin.x;
    if (x < self.leftView.frame.origin.x + 45) {
        right.origin.x = self.leftView.frame.origin.x + 45;
    }
    if (x > self.frame.size.width-45) {
        right.origin.x = self.frame.size.width-45;
    }
    
    float yDiff = self.frame.size.width - right.origin.x;
    float xBorder = 30 + self.leftView.frame.origin.x;
    float width = self.frame.size.width - xBorder - yDiff;
    
    self.topView.frame = CGRectMake(xBorder+5, self.topView.frame.origin.y, width, self.topView.frame.size.height);
    self.bottomView.frame = CGRectMake(xBorder+5, self.bottomView.frame.origin.y, width, self.bottomView.frame.size.height);
    
    x = right.origin.x;
    float w = self.frame.size.width-60+15;
    self.right = x / w;
    
    NSLog(@"RIGHT: %f", self.right);
    return right;
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
