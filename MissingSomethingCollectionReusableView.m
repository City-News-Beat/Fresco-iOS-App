//
//  MissingSomethingCollectionReusableView.m
//  Fresco
//
//  Created by Omar Elfanek on 4/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "MissingSomethingCollectionReusableView.h"

@interface MissingSomethingCollectionReusableView ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property BOOL isSetup;
@end

@implementation MissingSomethingCollectionReusableView

-(void)setup {
    if (!self.isSetup) {
        self.isSetup = TRUE;
    
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.textView.text];
        [attributedString addAttribute:NSLinkAttributeName value:UIApplicationOpenSettingsURLString range:NSMakeRange(self.textView.text.length-@"Settings.".length-1, @"Settings.".length)];
        [self.textView setAttributedText:attributedString];
        self.textView.delegate = (id<UITextViewDelegate>)self;
        
        NSArray *textViewGestureRecognizers = self.textView.gestureRecognizers;
        NSMutableArray *mutableArrayOfGestureRecognizers = [[NSMutableArray alloc] init];
        for (UIGestureRecognizer *gestureRecognizer in textViewGestureRecognizers) {
            if (![gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [mutableArrayOfGestureRecognizers addObject:gestureRecognizer];
            } else {
                UILongPressGestureRecognizer *longPressGestureRecognizer = (UILongPressGestureRecognizer *)gestureRecognizer;
                if (longPressGestureRecognizer.minimumPressDuration < 0.3) {
                    [mutableArrayOfGestureRecognizers addObject:gestureRecognizer];
                }
            }
        }
        self.textView.gestureRecognizers = mutableArrayOfGestureRecognizers;
    }
    
    self.textView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    //SYSTEM != SANFRAN
    //Should be SFUIText-Light size 15
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    NSLog(@"test");
    return YES;
}


@end
