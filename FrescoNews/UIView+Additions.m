//
//  UIView+Additions.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)
- (UIView *)viewFromNib
{
    Class class = [self class];
    NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)addSubviewFromNib
{
    UIView *view = [self viewFromNib];
    view.frame = self.bounds;
    [self addSubview:view];
}

- (UIView *)viewFromNib:(NSString *)nibName usingClass:(Class)className
{
    for (id object in [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil]) {
        if ([[object class] isEqual:className]) {
            return object;
        }
    }
    return nil;
}
@end
