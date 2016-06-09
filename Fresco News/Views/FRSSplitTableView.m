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

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    [self setContentSize:CGSizeMake(self.frame.size.width * 2, self.frame.size.height)]; // always 2x width by height
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // content size
    [self setContentSize:CGSizeMake(self.frame.size.width * 2, self.frame.size.height)]; // always 2x width by height
    [self snapTables];
}

-(void)snapTables {
    
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    return self;
}
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
    [self snapTables];
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
    [self snapTables];
}

@end
