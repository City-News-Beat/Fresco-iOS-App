//
//  FRSGalleryCompleteToast.m
//  Fresco
//
//  Created by Omar Elfanek on 3/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryCompleteToast.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

#define HEIGHT 40
#define YPOS 72

@interface FRSGalleryCompleteToast ()
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@end

@implementation FRSGalleryCompleteToast

- (instancetype)initWithAction:(SEL)action {
    self = [super init];
    
    if (self) {
        
        // Frame configuration
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - self.frame.size.width/2, YPOS, self.frame.size.width, self.frame.size.height);
        
        // Button configuration
        [self.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.layer.borderColor = [UIColor frescoShadowColor].CGColor;
        
    }
    
    return self;
}


- (void)show {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

@end
