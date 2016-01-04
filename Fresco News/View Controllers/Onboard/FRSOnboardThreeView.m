//
//  FRSOnboardThreeView.m
//  Fresco
//
//  Created by Omar Elfanek on 12/23/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSOnboardThreeView.h"

@interface FRSOnboardThreeView()

@property (strong, nonatomic) UIImageView *cloudIV;
@property (strong, nonatomic) UIImageView *leftArrowIV;
@property (strong, nonatomic) UIImageView *rightArrowIV;
@property (strong, nonatomic) UIImageView *televisionIV;
@property (strong, nonatomic) UIImageView *newspaperIV;
@property (strong, nonatomic) UIImageView *cashOneIV;
@property (strong, nonatomic) UIImageView *cashTwoIV;
@property (strong, nonatomic) UIImageView *cashThreeIV;

@end

@implementation FRSOnboardThreeView

-(instancetype)initWithOrigin:(CGPoint)origin{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 320, 288)];
    if (self){
        [self configureIV];
    }
    return self;
}

-(void)configureIV{
    
    NSInteger width = 144;
    NSInteger height = 96;
    CGFloat xOrigin = self.frame.size.width/2;
    CGFloat yOrigin = 23;
    
    if (IS_IPHONE_5){
        xOrigin = 80.5;
        yOrigin = 69.6;
    }
    
    self.cloudIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin - width/2, yOrigin, width, height)];
    self.cloudIV.image = [UIImage imageNamed:@"grey-cloud"];
    [self addSubview:self.cloudIV];
    
    self.leftArrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin - 28/2 - 30, 143, 28, 26)];
    self.leftArrowIV.image = [UIImage imageNamed:@"upload"];
    [self addSubview:self.leftArrowIV];
    
    self.rightArrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin - 28/2 + 30, 143, 28, 26)];
    self.rightArrowIV.image = [UIImage imageNamed:@"upload"];
    [self addSubview:self.rightArrowIV];
    
    self.televisionIV = [[UIImageView alloc] initWithFrame:CGRectMake(46, 193, 88, 72)];
    self.televisionIV.image = [UIImage imageNamed:@"television"];
    [self addSubview:self.televisionIV];
    
    self.newspaperIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin - 28/2 + 30, 193, 80, 72)];
    self.newspaperIV.image = [UIImage imageNamed:@"newspaper"];
    [self addSubview:self.newspaperIV];
    
}

@end
