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
@end
