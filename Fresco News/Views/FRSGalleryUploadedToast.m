//
//  FRSGalleryUploadedToast.m
//  Fresco
//
//  Created by Omar Elfanek on 3/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryUploadedToast.h"
#import "FRSNotificationHandler.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

#define HEIGHT 40
#define YPOS 72

@interface FRSGalleryUploadedToast ()
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@end

@implementation FRSGalleryUploadedToast

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Configure nib
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI {
    // Frame configuration
    self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - self.frame.size.width/2, YPOS, self.frame.size.width, self.frame.size.height);
    
    // Button configuration
    self.actionButton.layer.borderColor = [UIColor frescoShadowColor].CGColor;
    
    // Add shadow to view
    [self addShadowWithColor:[UIColor colorWithWhite:0 alpha:0.1] radius:2 offset:CGSizeMake(0, 4)];
}

- (IBAction)actionButtonTapped:(id)sender {
    
    if (self.galleryID) {
        [FRSNotificationHandler segueToGallery:self.galleryID];
    }

    [self hide];
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
    
    [self performSelector:@selector(hide) withObject:self afterDelay:10];
}

- (void)hide {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.frame.origin.x, YPOS +10, self.frame.size.width, self.frame.size.height);
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(self.frame.origin.x, -HEIGHT, self.frame.size.width, self.frame.size.height);
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}


@end
