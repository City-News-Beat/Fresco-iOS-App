//
//  UIView+Additions.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface UIView (Additions)
- (void)addSubviewFromNib;
- (UIView *)viewFromNib:(NSString *)nibName usingClass:(Class)className;

@end
