//
//  FRSFileTagViewManager.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseViewController.h"
#import "FRSCameraConstants.h"

@protocol FRSFileTagViewManagerDelegate <NSObject>

@required
@property (nonatomic, strong) UIView *view;


@end

@interface FRSFileTagViewManager : NSObject

- (instancetype)initWithDelegate:(id)delegate;
- (void)showTagViewForCaptureMode:(FRSCaptureMode)captureMode andTagViewMode:(FRSTagViewMode)tagViewMode;

@end
