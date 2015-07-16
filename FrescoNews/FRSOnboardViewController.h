//
//  FRSOnboardViewController.h
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSOnboardViewControllerDelegate

- (void)nextPageClicked:(NSInteger)index;

@end

@interface FRSOnboardViewController : UIViewController

/*
** Delegate reference for FRSOnboardViewControllerDelegate
*/

@property (strong, nonatomic) id<FRSOnboardViewControllerDelegate> frsTableViewCellDelegate;

/*
** Index of Onboard View in page control
*/

@property (assign, nonatomic) NSInteger index;

@end
