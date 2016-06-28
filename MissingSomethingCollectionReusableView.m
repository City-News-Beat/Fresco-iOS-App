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
    if(IS_IPHONE_6_PLUS){
        self.settingsRightConstraint.constant = 85;
    }else if(IS_IPHONE_5){
        self.settingsTopConstraint.constant = 45;
        self.settingsRightConstraint.constant = 117;
        self.chatWithTopConstraint.constant = 30;
        self.chatWithRightConstraint.constant = 100;
        [super removeConstraint:self.chatWithLeftConstraint];
        self.questionLeftConstraint.constant = 50;
    }
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
