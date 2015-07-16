//
//  FRSReplaceSegue.m
//  FrescoNews
//
//  Created by Fresco News on 6/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSReplaceSegue.h"

// this makes pushes onto the NC stack always result in one VC deep
// this is good for when you want to prevent backing out as in FirstRun
@implementation FRSReplaceSegue
-(void)perform {
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    // make the new view controller the root view controller
    navigationController.viewControllers = @[destinationController];
}
@end
