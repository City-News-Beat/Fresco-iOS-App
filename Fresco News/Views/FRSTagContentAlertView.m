//
//  FRSTagContentAlertView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/30/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTagContentAlertView.h"

@implementation FRSTagContentAlertView

- (instancetype)initTagContentAlertView {
    self = [super init];
    
    if (self) {
        /* Title Label */
        [self configureWithTitle:@""];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 14.5];
        
        
    }
    
    return self;
}


- (void)showTagViewForCaptureMode:(FRSCaptureMode)captureMode andTagViewMode:(FRSTagViewMode)tagViewMode {
    [self removeUncommonViews];
    [self configureWithLineViewAtYposition:self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 15];

    switch (tagViewMode) {
        case FRSTagViewModeNewTag:
            self.titleLabel.text = @"SET CONTENT TYPE";
            [self configureWithLeftActionTitle:@"CANCEL" withColor:nil andRightCancelTitle:@"" withColor:nil];

            break;
        case FRSTagViewModeEditTag:
            self.titleLabel.text = @"EDIT CONTENT TYPE";
            [self configureWithLeftActionTitle:@"CANCEL" withColor:nil andRightCancelTitle:@"REMOVE SELECTION" withColor:nil];

            break;
            
        default:
            break;
    }
    [self adjustFrame];
    [self show];
    
}

- (void)adjustFrame {
    self.height = self.titleLabel.frame.size.height + self.leftActionButton.frame.size.height + 15;
    
    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
    NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;
    
    self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
}

- (void)removeUncommonViews {
    [self.line removeFromSuperview];
    self.line = nil;

    [self.leftActionButton removeFromSuperview];
    self.leftActionButton = nil;

    [self.rightCancelButton removeFromSuperview];
    self.line = nil;
}

@end
