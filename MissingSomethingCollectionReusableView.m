//
//  MissingSomethingCollectionReusableView.m
//  Fresco
//
//  Created by Omar Elfanek on 4/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "MissingSomethingCollectionReusableView.h"
#import "UIColor+Fresco.h"
#import <Smooch/Smooch.h>
#import "FRSUserManager.h"
#import "FRSModerationManager.h"

@interface MissingSomethingCollectionReusableView ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatWithTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatWithRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatWithLeftConstraint;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsRightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *missingSomethingMainText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *missingSomeMainTextTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTopConstraint;
@property BOOL isSetup;
@end

@implementation MissingSomethingCollectionReusableView

- (IBAction)pressedSettings:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (IBAction)pressedChatWithUs:(id)sender {
    [[FRSModerationManager sharedInstance] presentSmooch];
}

- (void)setup {
    
    // TODO: Refactor this
    // Currently, we are using white space to make room for the [settings] button, which changes depending on the device
    // and hard coding constants on the constraints.
    
    if (!self.isSetup) {
        self.isSetup = TRUE;
        self.textView.delegate = (id<UITextViewDelegate>)self;
    }
    self.textView.allowsEditingTextAttributes = false;
    NSString *attribText = [NSString stringWithFormat:@"We can only verify photos and videos from the past 7 days, taken with location data. If nothing is showing up, make sure Location is enabled in\n                 for next time."];
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.minimumLineHeight = 20;
    paragraphStyle.maximumLineHeight = 20;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.54],
                              NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                              NSParagraphStyleAttributeName : paragraphStyle
                              };
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:attribText attributes:attribs];
    
    self.missingSomethingMainText.attributedText = attributedText;
    self.settingsRightConstraint.constant = -45;

    if (IS_IPHONE_6_PLUS) {
        self.settingsRightConstraint.constant = -9;
        self.settingsTopConstraint.constant = 53.5;
        
        NSString *attribText = [NSString stringWithFormat:@"We can only verify photos and videos from the\n past 7 days, taken with location data. If\n nothing is showing up, make sure Location is\n enabled in                 for next time."];
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineSpacing = 1.2;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.54],
                                  NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                                  NSParagraphStyleAttributeName : paragraphStyle
                                  };
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:attribText attributes:attribs];
        
        [self.missingSomethingMainText setAttributedText:attributedText];
        self.questionTopConstraint.constant = -5;
        self.chatWithTopConstraint.constant = -3;
        self.missingSomeMainTextTopCon.constant = 75;
    } else if (IS_IPHONE_5) {
        NSString *attribText = [NSString stringWithFormat:@"We can only verify photos and videos from the past 7 days, taken with location data. If nothing is showing up, make sure Location is enabled in\n                  for next time."];
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.54],
                                  NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                                  NSParagraphStyleAttributeName : paragraphStyle
                                  };
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:attribText attributes:attribs];
        self.missingSomethingMainText.attributedText = attributedText;
        
        self.textView.allowsEditingTextAttributes = NO;
        
        self.settingsTopConstraint.constant = 73;
        self.settingsRightConstraint.constant = -43;
        self.chatWithTopConstraint.constant = 15;
        self.chatWithRightConstraint.constant = 110;
        [super removeConstraint:self.chatWithLeftConstraint];
        self.questionLeftConstraint.constant = 42;
    }
    [self.superview setBackgroundColor:[UIColor whiteColor]];
    
    [self.superview setBackgroundColor:[UIColor frescoBackgroundColorDark]];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
}

@end
