//
//  FRSSearchViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "FRSScrollingViewController.h"
#import "FRSNavigationController.h"

@interface FRSSearchViewController : FRSBaseViewController <UITextFieldDelegate>
{
    BOOL isInDefault;
    
    NSInteger userIndex;
    NSInteger storyIndex;
    NSInteger galleryIndex;
    BOOL hasSearched;
    NSString *defaultSearch;
}
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *galleries;
@property (nonatomic, retain) NSArray *defaultData;
@property BOOL shouldUpdateOnReturn;
-(void)search:(NSString *)string;
@end
