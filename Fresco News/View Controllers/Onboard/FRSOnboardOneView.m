//
//  FRSOnboardOneView.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSOnboardOneView.h"

#import "FRSAppConstants.h"
#import "UIFont+Fresco.h"

#import "OEParallax.h"

@interface FRSOnboardOneView()

@property (strong, nonatomic) UIImageView *globeIV;
@property (strong, nonatomic) UIImageView *flagOne;
@property (strong, nonatomic) UIImageView *flagTwo;
@property (strong, nonatomic) UIImageView *flagThree;
@property (strong, nonatomic) UIImageView *flagFour;

@end

@implementation FRSOnboardOneView



-(instancetype)initWithOrigin:(CGPoint)origin{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 320, 288)];
    if (self){
        [self configureText];
        [self configureIV];
        
//        [OEParallax createParallaxFromView:self.flagOne withMaxX:30 withMinX:-30 withMaxY:30 withMinY:-30];
//        [OEParallax createParallaxFromView:self.flagTwo withMaxX:30 withMinX:-30 withMaxY:30 withMinY:-30];
//        [OEParallax createParallaxFromView:self.flagThree withMaxX:30 withMinX:-30 withMaxY:30 withMinY:-30];
//        [OEParallax createParallaxFromView:self.flagFour withMaxX:30 withMinX:-30 withMaxY:30 withMinY:-30];
        
//        [OEParallax createParallaxFromView:self.globeIV withMaxX:10 withMinX:-10 withMaxY:10 withMinY:-10];

    }
    return self;
}

-(void)configureText{
    
    CGFloat screenWidth = self.bounds.size.width;
    CGFloat screenHeight = self.bounds.size.height;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2 - 144, -(screenHeight/10), 288, 67)];
    container.backgroundColor = [UIColor blueColor];
    [self addSubview:container];

    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(144-109, 0, 218, 19)]; //144 = containerWidth/2, 109 = headerWidth/2
    header.backgroundColor = [UIColor redColor];
    [header setText:MAIN_HEADER_1];
    [header setFont:[UIFont notaBoldWithSize:17]];
    [container addSubview:header];
    
    UILabel *subHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 288, 40)]; //144 = containerWidth/2, 109 = headerWidth/2
    subHeader.backgroundColor = [UIColor redColor];
    [subHeader setText:SUB_HEADER_1];
    [subHeader setFont:[UIFont systemFontOfSize:15]];
    subHeader.textAlignment = NSTextAlignmentCenter;
    subHeader.numberOfLines = 2;
    [container addSubview:subHeader];
    
}

-(void)configureIV{
    
    NSInteger width = 189.6;
    CGFloat xOrigin = 67.7;
    CGFloat yOrigin = 52.3;
    
    if (IS_IPHONE_5){
        width = 160;
        xOrigin = 80.5;
        yOrigin = 69.6;
    }
    
    self.globeIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, width, width)];
    self.globeIV.image = [UIImage imageNamed:@"earth"];
    [self addSubview:self.globeIV];
    
    self.flagOne = [[UIImageView alloc] initWithFrame: CGRectMake(160, 27, 55, 55)];
    self.flagOne.image = [UIImage imageNamed:@"assignment-right"];
    [self addSubview:self.flagOne];

    self.flagTwo = [[UIImageView alloc] initWithFrame: CGRectMake(55, 60, 55, 55)];
    self.flagTwo.image = [UIImage imageNamed:@"assignment-left"];
    [self addSubview:self.flagTwo];
    
    self.flagThree = [[UIImageView alloc] initWithFrame: CGRectMake(105, 137, 55, 55)];
    self.flagThree.image = [UIImage imageNamed:@"assignment-left"];
    [self addSubview:self.flagThree];
    
    self.flagFour = [[UIImageView alloc] initWithFrame: CGRectMake(200, 160, 55, 55)];
    self.flagFour.image = [UIImage imageNamed:@"assignment-right"];
    [self addSubview:self.flagFour];
    
}



@end
