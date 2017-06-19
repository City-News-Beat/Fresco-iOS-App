//
//  MissingSomethingCollectionReusableView.m
//  Fresco
//
//  Created by Omar Elfanek on 4/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "MissingSomethingCollectionReusableView.h"
#import "UIColor+Fresco.h"
#import "FRSModerationManager.h"
#import "NSString+Fresco.h"

@interface MissingSomethingCollectionReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
@property (weak, nonatomic) IBOutlet UITextView *subTextView;
@property BOOL isSetup;

@end

@implementation MissingSomethingCollectionReusableView


#pragma mark - UI Setup

- (void)setup {
    if (!self.isSetup) {
        self.isSetup = YES;
    }
    
    [self.superview setBackgroundColor:[UIColor whiteColor]];
    [self.superview setBackgroundColor:[UIColor frescoBackgroundColorDark]];
    
    [self.mainTextView setAttributedText:[NSString formattedAttributedStringFromString:@"Location data is required when submitting to an assignment. To make sure content is tagged with location data, enable Location in Settings." boldText:@"enable Location in Settings."]];
    
    [self.subTextView setAttributedText:[NSString formattedAttributedStringFromString:@"Have something we can't miss? Chat with us." boldText:@"Chat with us."]];

    
    UITapGestureRecognizer *mainTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainTextViewTapped)];
    [self.mainTextView addGestureRecognizer:mainTapRec];
    
    UITapGestureRecognizer *subTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subTextViewTapped)];
    [self.subTextView addGestureRecognizer:subTapRec];
}


#pragma mark - Actions

- (void)mainTextViewTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)subTextViewTapped {
    [[FRSModerationManager sharedInstance] presentSmooch];
}

@end
