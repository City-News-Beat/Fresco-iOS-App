//
//  FRSOnboardOneView.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSOnboardOneView.h"

#import "FRSAppConstants.h"

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
        [self configureGlobeIV];
    }
    return self;
}

-(void)configureGlobeIV{
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

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
