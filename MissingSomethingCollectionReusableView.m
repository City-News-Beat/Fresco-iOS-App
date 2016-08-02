//
//  MissingSomethingCollectionReusableView.m
//  Fresco
//
//  Created by Omar Elfanek on 4/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "MissingSomethingCollectionReusableView.h"
#import "UIColor+Fresco.h"

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
    NSLog(@"Pressed 'Chat with us'");
}

-(void)setup {
    if (!self.isSetup) {
        self.isSetup = TRUE;
        self.textView.delegate = (id<UITextViewDelegate>)self;
    }    
    self.textView.allowsEditingTextAttributes = false;
    NSString *attribText = [NSString stringWithFormat:@"We can only verify photos and videos from the past 24 hours, taken with location data. If nothing is showing up, make sure Location is enabled in                 for next time."];
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.minimumLineHeight = 20;
    paragraphStyle.maximumLineHeight = 20;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName:[[UIColor blackColor] colorWithAlphaComponent:0.54],
                              NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                              NSParagraphStyleAttributeName: paragraphStyle
                              };
    
    NSMutableAttributedString *attributedText =[[NSMutableAttributedString alloc] initWithString:attribText attributes:attribs];
    
    //[attributedText addAttribute:NSKernAttributeName
    //                value:@(1.03)
    //                range:NSMakeRange(0, attribText.length-1)];

    self.missingSomethingMainText.attributedText = attributedText;
    if(IS_IPHONE_6_PLUS){
        self.settingsRightConstraint.constant = -9;
        self.settingsTopConstraint.constant = 54;
        
        NSString *attribText = [NSString stringWithFormat:@"We can only verify photos and videos from the\n past 24 hours, taken with location data. If\n nothing is showing up, make sure Location is\n enabled in                 for next time."];
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineSpacing = 1.2;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName:[[UIColor blackColor] colorWithAlphaComponent:0.54],
                                  NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                                  NSParagraphStyleAttributeName: paragraphStyle
                                  };

        NSMutableAttributedString *attributedText =[[NSMutableAttributedString alloc] initWithString:attribText attributes:attribs];
    
        [self.missingSomethingMainText setAttributedText:attributedText];
        self.questionTopConstraint.constant = -5;
        self.chatWithTopConstraint.constant = -4;
        self.missingSomeMainTextTopCon.constant = 75;
    }else if(IS_IPHONE_5){
        NSString *attribText = [NSString stringWithFormat:@"We can only verify photos and videos from the past 24 hours, taken with location data. If nothing is showing up, make sure Location is enabled in\n                  for next time."];
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName:[[UIColor blackColor] colorWithAlphaComponent:0.54],
                                  NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                                  NSParagraphStyleAttributeName: paragraphStyle
                                  };
        
        NSMutableAttributedString *attributedText =[[NSMutableAttributedString alloc] initWithString:attribText attributes:attribs];
        
        //[attributedText addAttribute:NSKernAttributeName
        //                value:@(1.03)
        //                range:NSMakeRange(0, attribText.length-1)];
        
        self.missingSomethingMainText.attributedText = attributedText;

        self.settingsTopConstraint.constant = 73;
        self.settingsRightConstraint.constant = -43;
        self.chatWithTopConstraint.constant = 15;
        self.chatWithRightConstraint.constant = 110;
        [super removeConstraint:self.chatWithLeftConstraint];
        self.questionLeftConstraint.constant = 50;
    }
    [self.superview setBackgroundColor:[UIColor whiteColor]];

    [self.superview setBackgroundColor:[UIColor frescoBackgroundColorDark]];
    
//    NSString *strTextView = @"We can only verify photos and videos from the past 24 hours. If nothing’s showing up, make sure Location Services are turned on in Settings.";
//    
//    NSRange rangeBold = [strTextView rangeOfString:@"Settings"];
//    
//    UIFont *fontText = [UIFont boldSystemFontOfSize:15];
//    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
//    
//    NSMutableAttributedString *mutAttrTextViewString = [[NSMutableAttributedString alloc] initWithString:strTextView];
//    [mutAttrTextViewString setAttributes:dictBoldText range:rangeBold];
//    
//    [self.textView setAttributedText:mutAttrTextViewString];
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
}


@end
