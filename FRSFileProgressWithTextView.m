//
//  FRSFileProgressWithTextView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileProgressWithTextView.h"
#import "UIColor+Fresco.h"
#import "NSString+Fresco.h"
#import "FRSFileTagViewManager.h"

@interface FRSFileProgressWithTextView ()

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) SimpleActionBlock actionBlock;

@property BOOL isSetup;

@end

@implementation FRSFileProgressWithTextView


#pragma mark - UI Setup

- (void)setupWithShowPackageGuidelinesBlock:(SimpleActionBlock)actionBlock {
    if (!self.isSetup) {
        self.isSetup = YES;
    }
    
    self.actionBlock = actionBlock;
    
    [self.superview setBackgroundColor:[UIColor whiteColor]];
    [self.superview setBackgroundColor:[UIColor frescoBackgroundColorDark]];
        
    [[FRSFileTagViewManager sharedInstance] addObserver:self forKeyPath:@"packageProgressLevel" options:0 context:nil];

    UITapGestureRecognizer *mainTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainLabelTapped)];
    [self.mainLabel addGestureRecognizer:mainTapRec];
    
    [self updateMainText];
}

#pragma mark - Actions

- (void)mainLabelTapped {
    NSLog(@"progress mainLabelTapped.");
    if(self.actionBlock) self.actionBlock();
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == [FRSFileTagViewManager sharedInstance] && [keyPath isEqualToString:@"packageProgressLevel"]) {
        
        [self updateMainText];
    }
}

- (void)updateMainText {
    switch ([[FRSFileTagViewManager sharedInstance] packageProgressLevel]) {
        case FRSPackageProgressLevelOne:
        {
            [self.mainLabel setAttributedText:[NSString formattedAttributedStringFromString:@"Add more content to increase the strength of your package. Tap here to review guidelines." boldText:@"Tap here"]];
        }
            break;
        case FRSPackageProgressLevelTwo:
        {
            [self.mainLabel setAttributedText:[NSString formattedAttributedStringFromString:@"Almost there! Tap here to review the guidelines and increase the strength of your package." boldText:@"Tap here"]];
        }
            break;
        case FRSPackageProgressLevelThree:
        {
            [self.mainLabel setAttributedText:[NSString formattedAttributedStringFromString:@"Great Job! You created a perfect package! Tap here to review guidelines." boldText:@"Tap here"]];
        }
            break;
            
        default:
        {
            //FRSPackageProgressLevelZero
            [self.mainLabel setAttributedText:[NSString formattedAttributedStringFromString:@"Select media to begin creating a package. Tap here to review guidelines." boldText:@"Tap here"]];
        }
            break;
    }

}

- (void)dealloc {
    [[FRSFileTagViewManager sharedInstance] removeObserver:self forKeyPath:@"packageProgressLevel"];
}

@end
