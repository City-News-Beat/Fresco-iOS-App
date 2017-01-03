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

@interface FRSOnboardTwoView ()

@property (strong, nonatomic) UIImageView *cloudIV;
@property (strong, nonatomic) UIImageView *arrowIV;
@property (strong, nonatomic) UIImageView *cameraIV;
@property (strong, nonatomic) UIView *container;

@end

@implementation FRSOnboardTwoView

- (instancetype)initWithOrigin:(CGPoint)origin {
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 320, 288)];
    if (self) {
        [self configureText];
        [self configureIV];
        [self configureParallax];
        [self reset];
    }
    return self;
}

- (void)reset {
    self.arrowIV.alpha = 0;
    self.arrowIV.frame = CGRectMake(self.container.frame.size.width / 2 - 28 / 2, 143 + 18, 28, 26);
}

- (void)animate {
    [UIView animateWithDuration:0.25
                          delay:0
                        options:0
                     animations:^{
                       [self.arrowIV setFrame:CGRectMake(self.arrowIV.frame.origin.x, self.arrowIV.frame.origin.y - 18, self.arrowIV.frame.size.width, self.arrowIV.frame.size.height)];
                       [self.arrowIV setAlpha:1];
                     }
                     completion:^(BOOL finished){
                         //Finished animation
                     }];
}

- (void)configureText {
    CGFloat screenWidth = self.bounds.size.width;
    CGFloat offset = 138; // default

    if (IS_IPHONE_5) {
        offset = 138;
    } else if (IS_STANDARD_IPHONE_6) {
        offset = 164;
    } else if (IS_STANDARD_IPHONE_6_PLUS) {
        offset = 172;
    }

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 144, offset, 288, 67)];
    [self addSubview:container];

    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(144 - 109, 0, 218, 19)]; //144 = containerWidth/2, 109 = headerWidth/2
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

- (void)configureIV {
    NSInteger width = 144;
    NSInteger height = 96;
    CGFloat yOrigin = 23;
    CGFloat offset;
    CGFloat camWidth = 80;
    CGFloat camHeight = 72;

    if (IS_IPHONE_5) {
        yOrigin = 23;
        offset = 205;
    } else if (IS_STANDARD_IPHONE_6) {
        offset = 263;
    } else if (IS_STANDARD_IPHONE_6_PLUS) {
        offset = 295;
        camWidth = 96;
        camHeight = 86.4;
    }

    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, offset, 320, 288)];
    [self addSubview:self.container];

    self.cloudIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.container.frame.size.width / 2 - width / 2, yOrigin - 5, width, height)];
    self.cloudIV.image = [UIImage imageNamed:@"cloud"];
    [self.container addSubview:self.cloudIV];

    self.arrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.container.frame.size.width / 2 - 28 / 2, 143, 28, 26)];
    self.arrowIV.image = [UIImage imageNamed:@"upload"];
    [self.container addSubview:self.arrowIV];

    self.cameraIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.container.frame.size.width / 2 - camWidth / 2, 194, camWidth, camHeight)];
    self.cameraIV.image = [UIImage imageNamed:@"camera"];
    [self.container addSubview:self.cameraIV];
}

- (void)configureParallax {
    [OEParallax createParallaxFromView:self.cloudIV withMaxX:20 withMinX:-20 withMaxY:20 withMinY:-20];
}

@end
