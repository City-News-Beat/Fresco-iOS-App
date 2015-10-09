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

@property id<FRSProgressViewDelegate> delegate;

@property CGFloat *progressPercent;

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count;

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count andIndex:(NSInteger)index;

- (void)animateProgressViewAtPercent:(CGFloat)percent;

- (void)animateFilledCirclesFromIndex:(NSInteger)index;

- (void)animateEmptyCirclesFromIndex:(NSInteger)index;


@end
