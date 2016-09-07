//
//  FRSAssignmentsViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import <CoreData/CoreData.h>
#import "MagicalRecord.h"
#import "FRSAssignment.h"
#import "Fresco.h"

@interface FRSAssignmentsViewController : FRSBaseViewController <UIScrollViewDelegate>
{
    __weak UIScrollView *currentScroller; // weak b/c we only want to hold reference when in view
    BOOL isScrolling;
    
    NSTimer *scrollTimer;
    BOOL notFirstFetch;
}

-(void)setInitialMapRegion;
-(instancetype)initWithActiveAssignment:(NSString *)assignmentID;
-(void)focusOnAssignment:(FRSAssignment *)assignment;

@property (nonatomic) BOOL hasDefault;
@property (nonatomic, retain) NSString *defaultID;

@end
