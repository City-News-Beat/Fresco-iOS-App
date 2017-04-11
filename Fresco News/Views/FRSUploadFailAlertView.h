//
//  FRSUploadFailAlertView.h
//  Fresco
//
//  Created by Omar Elfanek on 3/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSAlertView.h"

@interface FRSUploadFailAlertView : FRSAlertView

- (instancetype)initUploadFailAlertViewWithError:(NSError *)error;

@end
