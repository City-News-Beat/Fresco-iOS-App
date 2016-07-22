//
//  FRSNavigationBar.m
//  Fresco
//
//  Created by Philip Bernstein on 6/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSNavigationBar.h"

@implementation FRSNavigationBar

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    CGRect navFrame = self.frame;
    navFrame.origin.y -= 20;
    navFrame.size.height += 20;
    navFrame.size.width = 0;
    _progressView = [[UIView alloc] initWithFrame:navFrame];
    _progressView.backgroundColor = [UIColor colorWithRed:1.00 green:0.71 blue:0.00 alpha:1.0];
    
    [self addSubview:_progressView];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSUploadUpdate" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSDictionary *update = notification.userInfo;
        
        if ([update[@"type"] isEqualToString:@"progress"]) {
            NSNumber *uploadPercentage = update[@"percentage"];
            float percentage = [uploadPercentage floatValue];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect navFrame = self.frame;
                navFrame.origin.y -= 40;
                navFrame.size.height += 20;
                navFrame.size.width = self.frame.size.width * percentage;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:.05 animations:^{
                        _progressView.frame = navFrame;
                    }];
                });
            });
        }
        else if ([update[@"type"] isEqualToString:@"completion"]) {
            CGRect navFrame = self.frame;
            navFrame.origin.y -= 20;
            navFrame.size.height += 20;
            navFrame.size.width = 0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.2 animations:^{
                    _progressView.alpha = 0;

                } completion:^(BOOL finished) {
                    _progressView.frame = navFrame;
                    _progressView.alpha = 1;
                }];
            });
        }
        else if ([update[@"type"] isEqualToString:@"failure"]) {
            CGRect navFrame = self.frame;
            navFrame.origin.y -= 20;
            navFrame.size.height += 20;
            navFrame.size.width = 0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.2 animations:^{
                    _progressView.alpha = 0;

                } completion:^(BOOL finished) {
                    _progressView.frame = navFrame;
                    _progressView.alpha = 1;
                }];
            });
            
        }
        
    }];

}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect progressFrame = _progressView.frame;
    progressFrame.size.height = frame.size.height + 20;
    _progressView.frame = progressFrame;
}

@end
