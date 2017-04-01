//
//  FRSAlertView.m
//  Fresco
//
//  Created by Omar Elfanek on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAlertView.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import <MapKit/MapKit.h>
#import <Contacts/Contacts.h>
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "NSString+Validation.h"

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@interface FRSAlertView ()
@end

@implementation FRSAlertView

-(instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
    
    [self configureDarkOverlay];
    
    /* Alert Box */
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self addShadowAndClip];

}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate {
    self = [super init];
    if (self) {
        [self commonInit];
        
        self.delegate = delegate;

        [self configureWithTitle:title];

        [self configureWithMessage:message];

        [self configureWithLineViewAtYposition:self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5];
        
        [self configureWithLeftActionTitle:actionTitle withColor:nil andRightCancelTitle:cancelTitle withColor:cancelTitleColor];

        [self adjustFrame];

    }
    self.delegate = delegate;
    return self;
}

- (void)show {
    /* keyWindow places the view above all. Add overlay view first, and then alertView*/
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.inputViewController.view endEditing:YES];
    
    [self animateIn];
}

- (void)adjustFrame {
    self.height = self.leftActionButton.frame.size.height + self.messageLabel.frame.size.height + self.titleLabel.frame.size.height + 15;

    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
    NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;

    self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
}

- (void)addShadowAndClip {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.1;
    self.layer.cornerRadius = 2;
}

- (void)rightCancelTapped {
    [self animateOut];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didPressButton:atIndex:)]) {
        [self.delegate didPressButton:self atIndex:1];
    }

    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.didPresentPermissionsRequest = NO;
}

- (void)leftActionTapped {
    [self animateOut];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didPressButton:atIndex:)]) {
        [self.delegate didPressButton:self atIndex:0];
    }

    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.didPresentPermissionsRequest = NO;
}

- (void)animateIn {
    /* Set default state before animating in */
    self.transform = CGAffineTransformMakeScale(1.175, 1.175);
    self.alpha = 0;

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.alpha = 1;
                       self.titleLabel.alpha = 1;
                       self.rightCancelButton.alpha = 1;
                       self.leftActionButton.alpha = 1;
                       self.overlayView.alpha = 0.26;
                       self.transform = CGAffineTransformMakeScale(1, 1);

                     }
                     completion:nil];
}

- (void)animateOut {
    [UIView animateWithDuration:0.25
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{

          self.alpha = 0;
          self.titleLabel.alpha = 0;
          self.rightCancelButton.alpha = 0;
          self.leftActionButton.alpha = 0;
          self.overlayView.alpha = 0;
          self.transform = CGAffineTransformMakeScale(0.9, 0.9);

        }
        completion:^(BOOL finished) {
          [self removeFromSuperview];
        }];
}

- (void)configureDarkOverlay {
    /* Dark Overlay */
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    [self addSubview:(self.overlayView)];
}

- (void)dismiss {
    [self animateOut];

    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.dismissKeyboardTap];
    [self removeFromSuperview];
}

#pragma mark - Configure Views

-(void)configureWithTitle:(NSString *)title {
    /* Title Label */
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
    [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = title;
    self.titleLabel.alpha = .87;
    [self addSubview:self.titleLabel];
}

-(void)configureWithMessage:(NSString *)message {
    /* Body Label */
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];
    [attributedMessage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
    
    [self configureWithAttributedMessage:attributedMessage];
}

-(void)configureWithAttributedMessage:(NSMutableAttributedString *)attributedMessage {
    /* Body Label */
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
    self.messageLabel.alpha = .54;
    self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageLabel.numberOfLines = 0;
    
    self.messageLabel.attributedText = attributedMessage;
    
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.messageLabel sizeToFit];
    self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
    [self addSubview:self.messageLabel];
}

-(void)configureWithLineViewAtYposition:(CGFloat)ypos {
    /* Action Shadow */
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, ypos, ALERT_WIDTH, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self addSubview:line];
}

-(void)configureWithLeftActionTitle:(NSString *)actionTitle withColor:(UIColor *)actionTitleColor andRightCancelTitle:(NSString *)cancelTitle withColor:(UIColor *)cancelTitleColor{
    if ([cancelTitle isEqual:@""]) {
        /* Single Action Button */
        self.leftActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.leftActionButton addTarget:self action:@selector(leftActionTapped) forControlEvents:UIControlEventTouchUpInside];
        self.leftActionButton.frame = CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, ALERT_WIDTH, 44);
        if(actionTitleColor) {
            [self.leftActionButton setTitleColor:actionTitleColor forState:UIControlStateNormal];
        }
        else {
            [self.leftActionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        }
        [self.leftActionButton setTitle:actionTitle forState:UIControlStateNormal];
        [self.leftActionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.leftActionButton];
    } else {
        /* Left Action */
        self.leftActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.leftActionButton addTarget:self action:@selector(leftActionTapped) forControlEvents:UIControlEventTouchUpInside];
        self.leftActionButton.frame = CGRectMake(16, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 121, 44);
        self.leftActionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        if(actionTitleColor) {
            [self.leftActionButton setTitleColor:actionTitleColor forState:UIControlStateNormal];
        }
        else {
            [self.leftActionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        }
        [self.leftActionButton setTitle:actionTitle forState:UIControlStateNormal];
        [self.leftActionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.leftActionButton];
        
        /* Right Action */
        self.rightCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.rightCancelButton.frame = CGRectMake(169, self.leftActionButton.frame.origin.y, 101, 44);
        [self.rightCancelButton addTarget:self action:@selector(rightCancelTapped) forControlEvents:UIControlEventTouchUpInside];
        if(cancelTitleColor) {
            [self.rightCancelButton setTitleColor:cancelTitleColor forState:UIControlStateNormal];
        }
        else {
            [self.rightCancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        }
        [self.rightCancelButton setTitle:cancelTitle forState:UIControlStateNormal];
        [self.rightCancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.rightCancelButton sizeToFit];
        [self.rightCancelButton setFrame:CGRectMake(self.frame.size.width - self.rightCancelButton.frame.size.width - 32, self.rightCancelButton.frame.origin.y, self.rightCancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.rightCancelButton];
    }
}

@end
