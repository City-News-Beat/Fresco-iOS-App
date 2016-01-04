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
#import "UIColor+Fresco.h"

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
        [self animate];
        
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
    
    CGFloat offset;
    
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
    [header setText:MAIN_HEADER_1];
    [header setTextColor:[UIColor frescoDarkTextColor]];
    [header setFont:[UIFont notaBoldWithSize:17]];
    header.textAlignment = NSTextAlignmentCenter;
    [container addSubview:header];
    
    UILabel *subHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 288, 40)]; //144 = containerWidth/2, 109 = headerWidth/2
    [subHeader setText:SUB_HEADER_1];
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
    
    NSInteger width = 189.6;
    CGFloat xOrigin = 67.7;
    CGFloat yOrigin = 52.3;
    
    CGFloat offset;
    
    if (IS_IPHONE_5){
        width = 160;
        xOrigin = 80.5;
        yOrigin = 69.6;
        
        offset = 263;
    } else if (IS_STANDARD_IPHONE_6){
        offset = 263;
    } else if (IS_STANDARD_IPHONE_6_PLUS){
        offset = 295;
    }
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, offset, 320, 288)];
    [self addSubview:container];
    
    self.globeIV = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, width, width)];
    self.globeIV.image = [UIImage imageNamed:@"earth"];
    [container addSubview:self.globeIV];
    
    self.flagOne = [[UIImageView alloc] initWithFrame: CGRectMake(160, 27, 55, 55)];
    self.flagOne.image = [UIImage imageNamed:@"assignment-right"];
//    self.flagOne.layer.anchorPoint = CGPointMake(-.01, 1);
    [container addSubview:self.flagOne];

    self.flagTwo = [[UIImageView alloc] initWithFrame: CGRectMake(55, 60, 55, 55)];
    self.flagTwo.image = [UIImage imageNamed:@"assignment-left"];
//    self.flagTwo.layer.anchorPoint = CGPointMake(1, 1);

    [container addSubview:self.flagTwo];
    
    self.flagThree = [[UIImageView alloc] initWithFrame: CGRectMake(105, 137, 55, 55)];
    self.flagThree.image = [UIImage imageNamed:@"assignment-left"];
//    self.flagThree.layer.anchorPoint = CGPointMake(1, 1);
    [container addSubview:self.flagThree];
    
    self.flagFour = [[UIImageView alloc] initWithFrame: CGRectMake(200, 160, 55, 55)];
    self.flagFour.image = [UIImage imageNamed:@"assignment-right"];
//    self.flagFour.layer.anchorPoint = CGPointMake(-.01, 1);
    [container addSubview:self.flagFour];
    
//    /* DEBUG */
//    self.flagOne.backgroundColor = [UIColor blueColor];
//    self.flagTwo.backgroundColor = [UIColor greenColor];
//    self.flagThree.backgroundColor = [UIColor purpleColor];
//    self.flagFour.backgroundColor = [UIColor orangeColor];
}

- (void)animate {
    
    self.globeIV.alpha = 1;
    self.flagTwo.transform = CGAffineTransformMakeScale(0, 0);
    self.flagThree.transform = CGAffineTransformMakeScale(0, 0);
    self.flagOne.transform = CGAffineTransformMakeScale(0, 0);
    self.flagFour.transform = CGAffineTransformMakeScale(0, 0);
    
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.globeIV.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                     }
     
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.25
                                               delay:-0.1
                          
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.flagTwo.alpha = 1;
                                              self.flagTwo.transform = CGAffineTransformMakeScale(1.15, 1.15);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.15
                                                                    delay:0.0
                                               
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   self.flagTwo.transform = CGAffineTransformMakeScale(1, 1);
                                                                   
                                                                   
                                                               }
                                               
                                                               completion:^(BOOL finished) {
                                                                   
                                                               }];
                                              
                                          }];
                         
                     }];
    
    // BUBBLE 2
    
    [UIView animateWithDuration:0.25
                          delay:0.15
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.flagOne.alpha = 1;
                         self.flagOne.transform = CGAffineTransformMakeScale(1.15, 1.15);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.flagOne.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
    
    
    // BUBBLE 3
    
    [UIView animateWithDuration:0.25
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.flagThree.alpha = 1;
                         self.flagThree.transform = CGAffineTransformMakeScale(1.15, 1.15);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.flagThree.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
    
    
    // BUBBLE 4
    
    [UIView animateWithDuration:0.25
                          delay:0.65
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.flagFour.alpha = 1;
                         self.flagFour.transform = CGAffineTransformMakeScale(1.15, 1.15);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.flagFour.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
    
}



@end
