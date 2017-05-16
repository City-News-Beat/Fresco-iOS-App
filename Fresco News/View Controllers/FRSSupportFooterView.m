//
//  FRSSupportFooterView.m
//  Fresco
//
//  Created by Omar Elfanek on 5/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSupportFooterView.h"
#import "NSString+Fresco.h"

@implementation FRSSupportFooterView

- (instancetype)initWithDelegate:(id)delegate {
    self = [super init];

    if (self) {
        self.delegate = delegate;
        [self configureUI];
    }
    return self;
}


- (void)configureUI {
    self.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, 72);
    self.userInteractionEnabled = YES;
    
    UILabel *lineOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.frame.size.width, 20)];
    lineOne.attributedText = [NSString formattedAttributedStringFromString:@"Questions? We're here to help." boldText:@""];
    [self addSubview:lineOne];
    
    UILabel *lineTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.frame.size.width, 20)];
    lineTwo.attributedText = [NSString formattedAttributedStringFromString:@" Chat with us. " boldText:@"Chat with us."];
    [self addSubview:lineTwo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentSmooch)];
    [self addGestureRecognizer:tap];
}

- (void)presentSmooch {
    [self.delegate presentSmooch];
}

@end
