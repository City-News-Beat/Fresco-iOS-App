//
//  FRSSignUpAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/8/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSignUpAlertView.h"
#import "UIFont+Fresco.h"

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@interface FRSSignUpAlertView()

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *buttonShadow;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *actionButton;

@end

@implementation FRSSignUpAlertView

- (instancetype)initSignUpAlert {
    self = [super init];
    
    if (self) {
        
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        
        [self configureDarkOverlay];
        
        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"WAIT, DON'T GO";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Are you sure you don’t want to sign up for Fresco?"];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Are you sure you don’t want to sign up for Fresco?" length])];
        
        self.messageLabel.attributedText = attributedString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];
        
        /* Action Shadow */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];
        
        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(14, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 51, 44);
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];
        
        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 0, 44);
        [self.cancelButton addTarget:self action:@selector(returnToPreviousViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoRedColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"DELETE" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 70, ALERT_WIDTH, 140);
        
        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

- (void)returnToPreviousViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"returnToPreviousViewController" object:self];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"facebook-name"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebook-connected"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"twitter-handle"];
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

- (void)show {
    /* keyWindow places the view above all. Add overlay view first, and then alertView*/
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.inputViewController.view endEditing:YES];
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
                         self.actionButton.alpha = 1;
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
                         self.actionButton.alpha = 0;
                         self.overlayView.alpha = 0;
                         self.transform = CGAffineTransformMakeScale(0.9, 0.9);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)addShadowAndClip {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.1;
    self.layer.cornerRadius = 2;
}

- (void)cancelTapped {
    [self animateOut];
    
    if (self.delegate) {
        [self.delegate didPressButton:self atIndex:1];
    }
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.didPresentPermissionsRequest = NO;
}

@end
