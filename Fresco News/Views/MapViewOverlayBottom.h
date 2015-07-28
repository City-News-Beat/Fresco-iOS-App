//
//  MapViewOverlay.h
//  Fresco
//
//  Created by Nicolas Rizk on 7/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewOverlayBottom : UIView
//- (void)drawRect:(CGRect)rect;
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
@property (nonatomic) UIImage *image;
//- (void) overlayBottom;
@end
