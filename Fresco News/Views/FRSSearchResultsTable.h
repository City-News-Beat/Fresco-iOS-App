//
//  FRSSearchResultsTable.h
//  Fresco
//
//  Created by Philip Bernstein on 8/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSSearchResultsTable : UITableView
{
    
}
-(void)loadResults:(NSArray *)results; // 0->users 1-> stories 2-> galleries
@end
