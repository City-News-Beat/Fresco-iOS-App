//
//  FRSModerationAlertView.h
//  Fresco
//
//  Created by Maurice Wu on 3/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRSAlertView;

@interface FRSModerationAlertView : FRSAlertView

- (instancetype)initUserReportWithUsername:(NSString *)username delegate:(id)delegate;
- (instancetype)initGalleryReportDelegate:(id)delegate;

@end
