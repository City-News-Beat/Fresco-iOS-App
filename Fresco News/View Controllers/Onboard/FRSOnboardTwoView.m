//
//  FRSOnboardTwoView.m
//  Fresco
//
//  Created by Omar Elfanek on 12/23/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSOnboardTwoView.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "OEParallax.h"

@interface FRSOnboardTwoView()

@property (strong, nonatomic) UIImageView *cloudIV;
@property (strong, nonatomic) UIImageView *arrowIV;
@property (strong, nonatomic) UIImageView *cameraIV;

@end

@implementation FRSOnboardTwoView

-(instancetype)initWithOrigin:(CGPoint)origin{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 320, 288)];
    if (self){
        [self configureText];
        [self configureIV];
        [self configureParallax];
    }
    return self;
}

-(void)configureText{
    CGFloat screenWidth = self.bounds.size.width;
    CGFloat offset = 138; // default
    
    if (IS_IPHONE_5){
        offset = 138;
    } else if (IS_STANDARD_IPHONE_6) {
        offset = 164;
    } else if (IS_STANDARD_IPHONE_6_PLUS) {
        offset = 172;
    }
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2 - 144, offset, 288, 67)];
    [self addSubview:container];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(144-109, 0, 218, 19)]; //144 = containerWidth/2, 109 = headerWidth/2
    [header setText:MAIN_HEADER_2];
    [header setTextColor:[UIColor frescoDarkTextColor]];
    [header setFont:[UIFont notaBoldWithSize:17]];
    header.textAlignment = NSTextAlignmentCenter;
    [container addSubview:header];
    
    UILabel *subHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 288, 40)]; //144 = containerWidth/2, 109 = headerWidth/2
    [subHeader setText:SUB_HEADER_2];
    [subHeader setTextColor:[UIColor frescoMediumTextColor]];
    [subHeader setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
    subHeader.textAlignment = NSTextAlignmentCenter;
    subHeader.numberOfLines = 2;
    [container addSubview:subHeader];
    
    //    /* DEBUG */
    //    container.backgroundColor = [UIColor blueColor];
    //    header.backgroundColor = [UIColor redColor];
    //    subHeader.backgroundColor = [UIColor redColor];
}

-(void)configureIV{
    NSInteger width = 144;
    NSInteger height = 96;
    CGFloat xOrigin = self.frame.size.width/2;
    CGFloat yOrigin = 23;
    CGFloat offset;
    CGFloat camWidth = 80;
    CGFloat camHeight = 72;
    
    if (IS_IPHONE_5){
        xOrigin = self.frame.size.width;
        yOrigin = 23;
        offset = 205;
    } else if (IS_STANDARD_IPHONE_6){
        offset = 263;
    } else if (IS_STANDARD_IPHONE_6_PLUS){
        offset = 295;
        camWidth = 96;
        camHeight = 86.4;
    }
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, offset, 320, 288)];
    [self addSubview:container];

    self.cloudIV = [[UIImageView alloc] initWithFrame:CGRectMake(container.frame.size.width/2 - width/2, yOrigin-5, width, height)];
    self.cloudIV.image = [UIImage imageNamed:@"cloud"];
    [container addSubview:self.cloudIV];
    
    self.arrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(container.frame.size.width/2 - 28/2, 143, 28, 26)];
    self.arrowIV.image = [UIImage imageNamed:@"upload"];
    [container addSubview:self.arrowIV];
    
    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(container.frame.size.width/2 - camWidth/2, 194, camWidth, camHeight)];
    self.cameraIV.image = [UIImage imageNamed:@"camera"];
    [container addSubview:self.cameraIV];
}

-(void)configureParallax{
    [OEParallax createParallaxFromView:self.cloudIV withMaxX:20 withMinX:-20 withMaxY:20 withMinY:-20];
}

@end
