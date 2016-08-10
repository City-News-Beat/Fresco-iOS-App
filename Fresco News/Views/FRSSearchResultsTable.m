//
//  FRSSearchResultsTable.m
//  Fresco
//
//  Created by Philip Bernstein on 8/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSearchResultsTable.h"

@implementation FRSSearchResultsTable

-(void)loadResults:(NSArray *)results {
    if (results.count != 3) {
        return;
    }
    
    self.users = results[0];
    self.stories = results[1];
    self.galleries = results[2];
    [self reloadData];
}

-(void)commonInit {
    
}

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

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}
@end
