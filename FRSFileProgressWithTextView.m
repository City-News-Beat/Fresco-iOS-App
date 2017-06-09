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
    
    [self.mainLabel setAttributedText:[NSString formattedAttributedStringFromString:@"Great Job! You created a perfect package! \nTap here to review guidelines." boldText:@"Tap here"]];
    
    UITapGestureRecognizer *mainTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainLabelTapped)];
    [self.mainLabel addGestureRecognizer:mainTapRec];
    
}

#pragma mark - Actions

- (void)mainLabelTapped {
    NSLog(@"progress mainLabelTapped.");
    if(self.actionBlock) self.actionBlock();
}

@end
