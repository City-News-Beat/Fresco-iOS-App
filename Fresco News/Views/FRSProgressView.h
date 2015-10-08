//
//  FRSProgressView.h
//  Fresco
//
//  Created by Omar Elfanek on 10/2/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSProgressViewDelegate <NSObject>

@required

- (void)nextButtonTapped;

@end

@interface FRSProgressView : UIView

- (void)animateProgressViewAtPercent:(CGFloat)percent;

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count;

@property CGFloat *progressPercent;

@property id<FRSProgressViewDelegate> delegate;


@end
