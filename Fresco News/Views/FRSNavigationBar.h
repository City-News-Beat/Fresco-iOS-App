//
//  FRSNavigationBar.h
//  Fresco
//
//  Created by Philip Bernstein on 6/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSNavigationBar : UINavigationBar
@property (nonatomic, retain) UIView *progressView;
@property (nonatomic, retain) UIView *failureView;
@property (nonatomic, retain) NSDate *lastAnimated;
@end
