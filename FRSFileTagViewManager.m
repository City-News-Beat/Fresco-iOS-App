//
//  FRSFileTagViewManager.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagViewManager.h"
#import "FRSTagContentAlertView.h"

@interface FRSFileTagViewManager ()

@property(weak, nonatomic) id<FRSFileTagViewManagerDelegate> delegate;
@property(strong, nonatomic) FRSTagContentAlertView *tagAlertView;

@end

@implementation FRSFileTagViewManager

- (instancetype)initWithDelegate:(id<FRSFileTagViewManagerDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        [self setupTagAlertView];
    }
    return self;
}

- (void)setupTagAlertView {
    self.tagAlertView = [[FRSTagContentAlertView alloc] initTagContentAlertView];
}

- (void)showTagViewForCaptureMode:(FRSCaptureMode)captureMode andTagViewMode:(FRSTagViewMode)tagViewMode {
    [self.tagAlertView showTagViewForCaptureMode:captureMode andTagViewMode:tagViewMode];
}

@end
