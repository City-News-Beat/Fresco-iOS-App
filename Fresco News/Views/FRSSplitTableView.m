//
//  FRSSplitTableView.m
//  Fresco
//
//  Created by Philip Bernstein on 6/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSplitTableView.h"

@implementation FRSSplitTableView
@synthesize primaryTableView = _primaryTableView, secondaryTableView = _secondaryTableView;

-(UITableView *)primaryTableView {
    return _primaryTableView;
}

-(void)setPrimaryTableView:(UITableView *)primaryTableView {
    
    if (primaryTableView != _primaryTableView && _primaryTableView) {
        // remove old, add new
        [_primaryTableView removeFromSuperview];
        [self addSubview:primaryTableView];
        
        // configure constraints
        // content size
    }
    
    _primaryTableView = primaryTableView;
}

-(UITableView *)secondaryTableView {
    return _secondaryTableView;
}

-(void)setSecondaryTableView:(UITableView *)secondaryTableView {
    
    if (secondaryTableView != _secondaryTableView && _secondaryTableView) {
        // remove old, add new
        [_secondaryTableView removeFromSuperview];
        [self addSubview:secondaryTableView];
        
        // configure constraints
        // content size
    }
    
    _secondaryTableView = secondaryTableView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
