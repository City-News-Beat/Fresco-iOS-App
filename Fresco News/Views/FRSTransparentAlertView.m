//
//  FRSTransparentAlertView.m
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTransparentAlertView.h"

@interface FRSTransparentAlertView ();

@property NSInteger currentTipCount;
@property FRSCaptureMode captureMode;

@end

@implementation FRSTransparentAlertView

- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode tipIndex:(NSInteger)tipIndex {
    
    self.currentTipCount = tipIndex++;
    self.captureMode = captureMode;
    
    self = [self initWithTitle:[self titleForCaptureMode:captureMode]
                       message:[self messageForCaptureMode:captureMode]
                   actionTitle:@"CLOSE"
                   cancelTitle:[self isLastTipForCaptureMode:captureMode] ? @"NEXT TIP" : @"LEARN MORE"
              cancelTitleColor:[UIColor whiteColor]
                      delegate:self];
    
    if (self) {
        self.backgroundColor = [UIColor frescoTransparentDarkColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        [self.leftActionButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.54] forState:UIControlStateNormal];
        self.line.backgroundColor = [UIColor clearColor];
        
        [self setTipCountForCaptureMode:captureMode];
    }
    
    return self;
}



#pragma mark - Data Source


/**
 The data source with all the tips, indexed by their FRSCaptureMode.

 @return NSDictionary populated with NSArrays of NSStrings.
 */
- (NSDictionary *)tipsDictionary {
    
    NSDictionary *tipsDictionary;
    tipsDictionary = @{
                       @(FRSCaptureModeInterview) : @[@"Interview tip #1", @"Interview tip #2", @"Interview tip #3"],
                       @(FRSCaptureModePan)       : @[@"Pan tip #1", @"Pan tip #2", @"Pan tip #3"],
                       @(FRSCaptureModeWide)      : @[@"Wide tip #1", @"Wide tip #2", @"Wide tip #3"],
                       @(FRSCaptureModeVideo)     : @[@"Video tip #1", @"Video tip #2", @"Video tip #3"],
                       @(FRSCaptureModePhoto)     : @[@"Photo tip #1", @"Photo tip #2", @"Photo tip #3", @"Photo tip #4"]
                       };
    
    return tipsDictionary;
}



#pragma mark - Helpers


/**
 Sets the title for the given FRSCaptureMode at the current index.

 @param captureMode FRSCaptureMode to be used to pull the index out of the data source.
 @return NSString The title for the given capture mode at the current index.
 */
- (NSString *)titleForCaptureMode:(FRSCaptureMode)captureMode {
    
    NSString *title = [NSString stringWithFormat:@"Tip (%ld/%ld)", self.currentTipCount, [self totalTipCountFromCaptureMode:captureMode]];
    
    return title;
}


/**
 Sets the message body for the given FRSCaptureMode at the current index.

 @param captureMode FRSCaptureMode to be used to pull the index out of the data source.
 @return NSString The message body for the given capture mode at the current index.
 */
- (NSString *)messageForCaptureMode:(FRSCaptureMode)captureMode {
    return [self tipsDictionary][@(captureMode)][self.currentTipCount-1];
}

/**
 This method sets the tip count for the given capture mode.

 @param captureMode FRSCaptureMode to be used as a safety net. We want to reset self.currentTipCount if it's above the max number in the data source to avoid accessing something at an index that is beyond bounds.
 */
- (void)setTipCountForCaptureMode:(FRSCaptureMode)captureMode {
    if ([self isLastTipForCaptureMode:captureMode]) {
        self.currentTipCount++;
    } else {
        self.currentTipCount = 1;
    }
}

/**
 This method checks if the current tip is the last tip in the tipsDictionary.

 @param captureMode FRSCaptureMode to be used as the key to determine if the current tip is the last tip.
 @return BOOL
 */
- (BOOL)isLastTipForCaptureMode:(FRSCaptureMode)captureMode {
    return ([self totalTipCountFromCaptureMode:captureMode] > self.currentTipCount);
}

/**  
 This method uses the tipsDictionary and pulls out the total count for the given FRSCaptureMode.

 @param captureMode FRSCaptureMode that will be used to as the key to determine how many tips are inside the dictionary.
 @return NSInteger count of total tips in the tipsDictionary at the given FRSCaptureMode index.
 */
- (NSInteger)totalTipCountFromCaptureMode:(FRSCaptureMode)captureMode {
    return [[self tipsDictionary][@(captureMode)] count];
}



#pragma mark - Actions

- (void)leftActionTapped {
    [self dismiss];
    self.currentTipCount = 0;
}

- (void)rightCancelTapped {
    
    if ([self.rightCancelButton.titleLabel.text isEqualToString:@"LEARN MORE"]) {
        // Segue to tips page, dismiss, and reset the tips count.
        [self leftActionTapped];
    } else {
        // We're delaying the second alert from showing up right after the previous one has been dismissed.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            FRSTransparentAlertView *alert = [[FRSTransparentAlertView alloc] initWithCaptureMode:self.captureMode tipIndex:self.currentTipCount];
            [alert show];
        });
        
        [self dismiss];
    }
}


@end
