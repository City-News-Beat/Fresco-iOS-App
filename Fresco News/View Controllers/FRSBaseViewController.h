//
//  FRSBaseViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/7/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface FRSBaseViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *galleries;


/*
** Navigation Methods
*/

- (void)navigateToMainApp;

- (void)navigateToFirstRun;

- (void)navigateToCamera;

@end
