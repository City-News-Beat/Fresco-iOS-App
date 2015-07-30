//
//  AssignmentOnboardView.m
//  Fresco
//
//  Created by Nicolas Rizk on 7/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AssignmentOnboardView.h"

@interface AssignmentOnboardView()

@property (nonatomic) CGSize intrinsicContentSize;

@end

@implementation AssignmentOnboardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        //        1. Load .xib
        [[NSBundle mainBundle] loadNibNamed:@"AssignmentOnboardView" owner:self options:nil];
        
        //        2. adjust bounds
        NSLog(@"frame: %@", NSStringFromCGRect(self.view.bounds));
        self.bounds = self.view.bounds;
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        visualEffectView.frame = self.bounds;
        [self addSubview:visualEffectView];
        
        //        3. Add as a subview
        [self addSubview:self.view];
        
        [UILabel appearance].numberOfLines = 3;
        
        [_onboard1Label setText:@"Look around the map to see what’s\nhappening. Tap on the yellow dots\nto see more info and get directions."];
        
        [_onboard2Label setText:@"When the camera says you’re close\nenough, you’re ready to start taking\nphotos and videos!"];
        
        [_onboard3Label setText:@"If a photo or video in your gallery is\nused, we’ll tell you who used it and\nhow to get paid!"];
    
        [_letsGoButton setBackgroundColor:[UIColor colorWithHex:@"0077FF"]];
        
        _letsGoButton.layer.cornerRadius = 4;
        
        _intrinsicContentSize = self.bounds.size;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return _intrinsicContentSize;
}

//- (void)updateConstraints {
//    
//  self.onboard1Label.translatesAutoresizingMaskIntoConstraints = NO;
//  self.onboard1ImageView.translatesAutoresizingMaskIntoConstraints = NO;
//
//  NSDictionary *metrics = @{ @"height" : @30.0 };
//
//  NSDictionary *views = @{
//    @"onboard1ImageView" : self.onboard1ImageView,
//    @"onboard1Label" : self.onboard1Label
//  };
//  [self.view addConstraints:
//                 [NSLayoutConstraint
//                     constraintsWithVisualFormat:
//                         @"|-[onboard1Imageview]-[onboard1Label]-|"
//                                         options:NSLayoutFormatAlignAllCenterX
//                                         metrics:metrics
//                                           views:views]];
//}

- (IBAction)letsGoButtonTapped:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"letsGo"];
}

@end
