//
//  CameraViewController.h
//  FrescoNews
//
//  Created by Joshua C. Lerner on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface CameraViewController : UIViewController <UINavigationControllerDelegate>

- (void)cancel;
- (void)cancelAndReturnToPreviousTab:(BOOL)returnToPreviousTab;
- (IBAction)doneButtonTapped:(id)sender;

@end
