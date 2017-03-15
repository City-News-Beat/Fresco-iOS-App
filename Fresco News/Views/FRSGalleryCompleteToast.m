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
        
        // Add shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.1;
    }
    
    return self;
}

- (void)show {
    
    self.frame = CGRectMake(self.frame.origin.x, -HEIGHT, self.frame.size.width, self.frame.size.height);
    self.alpha = 0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.frame.origin.x, YPOS +15, self.frame.size.width, self.frame.size.height);
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(self.frame.origin.x, YPOS, self.frame.size.width, self.frame.size.height);
        } completion:nil];
    }];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [self performSelector:@selector(hide) withObject:self afterDelay:3];
}

- (void)hide {
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.frame.origin.x, YPOS +10, self.frame.size.width, self.frame.size.height);
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(self.frame.origin.x, -HEIGHT, self.frame.size.width, self.frame.size.height);
            self.alpha = 0;
        } completion:nil];
    }];
}


@end
