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

- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode tipIndex:(NSInteger)tipIndex delegate:(id)delegate {
    
    self.currentTipCount = tipIndex++;
    self.captureMode = captureMode;
    
    self = [self initWithTitle:[self titleForCaptureMode:captureMode]
                       message:[self messageForCaptureMode:captureMode]
                   actionTitle:@"CLOSE"
                   cancelTitle:[self isLastTipForCaptureMode:captureMode] ? @"NEXT TIP" : @"LEARN MORE"
              cancelTitleColor:[UIColor whiteColor]
                      delegate:delegate];
    self.delegate = delegate;
    
    if (self) {
        [self configureUI];
        [self setTipCountForCaptureMode:captureMode];
        
    }
    
    return self;
}


/**
 Configures the alert with a dark/transparent style, in the bottom third of the screen (4:3).
 */
- (void)configureUI {
    
    // Alert view color configuration
    self.backgroundColor = [UIColor frescoTransparentDarkColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.messageLabel.textColor = [UIColor colorWithWhite:1 alpha:0.87];
    [self.leftActionButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.54] forState:UIControlStateNormal];
    self.line.backgroundColor = [UIColor clearColor];

    [self addOffsetInY];
}

/**
 This places the view a bit higher than the center, to compensate for the camera footer.
 */
- (void)addOffsetInY {
    CGSize window = [UIScreen mainScreen].bounds.size;
    NSInteger offset = window.height - (window.width * 4 / 3);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - offset/2, self.frame.size.width, self.frame.size.height);

}

#pragma mark - Data Source

/**
 The data source with all the tips, indexed by their FRSCaptureMode.

 @return NSDictionary populated with NSArrays of NSStrings.
 */
- (NSDictionary *)tipsDictionary {
    
    NSDictionary *tipsDictionary;
    tipsDictionary = @{
                       @(FRSCaptureModeInterview) : @[@"Hold your device at the subject's eye level, and make sure you're not tilting your device up or down during the interview.",
                                                      @"Wait until your subject has finished speaking before talking again — don’t talk over their answer, even in agreement. It makes it hard to get a sound bite!",
                                                      @"Ask your subject to speak up! A good interview can quickly lose its chances of being purchased if the sound quality is poor.",
                                                      @"Avoid interviewing in places with machines humming, music playing or loud talking in the background. Your microphone is more likely to pick up sounds that your ears usually tune out.",
                                                      @"Make sure your back is to the light. In other words, always have a good amount of light coming from behind your camera and shining onto the subject",
                                                      @"Try to frame your subject with the action in the background. An interview becomes significantly more valuable when we can see what your subject is talking about!",
                                                      @"Remember the rule of thirds: having your focal point off-center (slightly left, right, up, or down) is more pleasing than placing them in the middle of the frame."],
                       @(FRSCaptureModePan)       : @[@"Plan the pan! Think about where you want to start and end the shot before you hit record.",
                                                      @"Slow and steady pans are best. Firmly plant your feet and rotate your body slowly to capture as much of the scene as possible",
                                                      @"It's better to pan too slow than too fast. The best pans last between 30 and 45 seconds. Take your time!"],
                       @(FRSCaptureModeWide)      : @[@"Take a step back! Try your best to capture the entire scene with this shot.",
                                                      @"Pick a point of interest. Take more than one wide shot if there are multiple points of interest on the scene.",
                                                      @"Move as little as possible. You want to keep your point of interest in the frame at all times."],
                       @(FRSCaptureModeVideo)     : @[@"Find the most captivating part of the scene and hit record! Avoid any sudden movements and focus on keeping your device steady.",
                                                      @"Use both hands, and tuck in your elbows for more stability.",
                                                      @"Make sure your shots are focused and exposed properly. Tap where you want your viewer to pay attention before you start recording.",
                                                      @"Pay attention to any parts of your frame that are so bright they appear white. For example, a clear blue sky will appear white if it’s overexposed.",
                                                      @"When capturing footage at night, try your best to avoid grainy video—that happens when you don't have enough light on your subject.",
                                                      @"Watch those fingers! Videos quickly lose quality when a finger makes its way into the shot."],
                       @(FRSCaptureModePhoto)     : @[@"When shooting action shots, be safe - take multiple shots at once.",
                                                      @"Never depend on just one shot. Some may come out blurry, the more shots the better. You can discard the bad photos later, but it never works the other way around."]
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
        [self.delegate segueToTipsAction];
        [self leftActionTapped];
    } else {
        [self.titleLabel setText:[self titleForCaptureMode:self.captureMode]];
        [self.messageLabel setText:[self messageForCaptureMode:self.captureMode]];
        
        if ([self isLastTipForCaptureMode:self.captureMode]) {
            [self.rightCancelButton setTitle:@"NEXT TIP"forState:UIControlStateNormal];
            self.currentTipCount++;
        } else {
            [self.rightCancelButton setTitle:@"LEARN MORE"forState:UIControlStateNormal];
        }
        
        [self adjustFrameForRotatedState];
        [self addOffsetInY];
    }
}




@end
