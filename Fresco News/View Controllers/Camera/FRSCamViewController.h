//
//  CameraViewController.h
//  FrescoNews
//
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface FRSCamViewController : UIViewController <UINavigationControllerDelegate>

- (void)cancelAndReturnToPreviousTab;

- (IBAction)doneButtonTapped:(id)sender;

@end