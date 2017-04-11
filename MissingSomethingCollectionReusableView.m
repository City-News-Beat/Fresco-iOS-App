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
    
    [self.mainTextView setAttributedText:[self formattedAttributedStringFromString:@"We can only verify photos and videos from the past seven days. If you are trying to submit to an assignment, location data on each photo or video is required. To make sure content is tagged with location data, enable Location in Settings." boldText:@"enable Location in Settings."]];
    
    [self.subTextView setAttributedText:[self formattedAttributedStringFromString:@"Have something we can't miss? Chat with us." boldText:@"Chat with us."]];

    
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


#pragma mark - Helpers

/**
 Convenience method to format an NSAttributedString with the proper paragraph style.
 
 @param text NSString Entire string to be returned.
 @param boldText NSString The string you want to be bold.
 @return NSAttributedString formatted and bolded where specified.
 */
- (NSAttributedString *)formattedAttributedStringFromString:(NSString *)text boldText:(NSString *)boldText {
    
    NSRange boldRange = [text rangeOfString:boldText];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineSpacing = 1.2;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.54],
                              NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                              NSParagraphStyleAttributeName : paragraphStyle
                              };
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
    UIFont *font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    [attributedText setAttributes:dictBoldText range:boldRange];
    
    return attributedText;
}

@end
