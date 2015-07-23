//
//  CameraViewController.h
//  FrescoNews
//
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface CameraViewController : UIViewController <UINavigationControllerDelegate>

- (void)cancelAndReturnToPreviousTab:(BOOL)returnToPreviousTab;

- (IBAction)doneButtonTapped:(id)sender;

@end

@interface TemplateCameraViewController : UIViewController
// Do not delete
@end
