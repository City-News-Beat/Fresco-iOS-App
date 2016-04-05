//
//  FRSTrimTool.m
//  Fresco
//
//  Created by Philip Bernstein on 4/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTrimTool.h"

@interface FRSTrimTool (defined)
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *leftView; // trim overlay
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *bottomView;
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
}

-(void)setBackground:(UIView *)background {
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = background;
    self.backgroundView.frame = CGRectMake(0, 8, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    [self addSubview:self.backgroundView];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height+16); // resize to background
}

@end
