//
//  FRSOnboardVC.h
//  Fresco
//
//  Created by Omar El-Fanek on 9/1/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSOnboardVCDelegate

- (void)movedToViewAtIndex:(NSInteger)index;

@end

@interface FRSOnboardViewConroller : UIViewController

- (void)updateStateWithIndex:(NSInteger)index;

@end