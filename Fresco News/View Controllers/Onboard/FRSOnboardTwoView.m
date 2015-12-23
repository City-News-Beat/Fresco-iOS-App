//
//  FRSOnboardTwoView.m
//  Fresco
//
//  Created by Omar Elfanek on 12/23/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSOnboardTwoView.h"

@interface FRSOnboardTwoView()

@property (strong, nonatomic) UIImageView *cloudIV;
@property (strong, nonatomic) UIImageView *arrowIV;
@property (strong, nonatomic) UIImageView *cameraIV;

@end

@implementation FRSOnboardTwoView

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
    self.cloudIV.image = [UIImage imageNamed:@"cloud"];
    [self addSubview:self.cloudIV];
    
    self.arrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin - 28/2, 143, 28, 26)];
    self.arrowIV.image = [UIImage imageNamed:@"upload"];
    [self addSubview:self.arrowIV];
    
    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin - 80/2, 194, 80, 72)];
    self.cameraIV.image = [UIImage imageNamed:@"camera"];
    [self addSubview:self.cameraIV];
    
}

@end
