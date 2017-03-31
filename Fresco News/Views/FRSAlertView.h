//
//  FRSAlertView.h
//  Fresco
//
//  Created by Omar Elfanek on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class FRSAlertView;

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@protocol FRSAlertViewDelegate <NSObject>

@required
@optional
- (void)didPressButton:(FRSAlertView *)alertView atIndex:(NSInteger)index;
- (void)logoutAlertAction;
- (void)reportGalleryAlertAction;
- (void)reportUserAlertAction;
- (void)blockUserAlertAction;
- (void)didPressRadioButtonAtIndex:(NSInteger)index;

@end

@interface FRSAlertView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardTap;
@property CGFloat height;

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate;

//configure views
-(void)configureWithTitle:(NSString *)title;
-(void)configureWithMessage:(NSString *)message;
-(void)configureWithAttributedMessage:(NSMutableAttributedString *)attributedMessage;
-(void)configureWithLineViewAtYposition:(CGFloat)ypos;
-(void)configureWithLeftActionTitle:(NSString *)actionTitle withColor:(UIColor *)actionTitleColor andRightCancelTitle:(NSString *)cancelTitle withColor:(UIColor *)cancelTitleColor;

- (void)show;
- (void)dismiss;
- (void)animateOut;
- (void)adjustFrame;
- (void)rightCancelTapped;
- (void)leftActionTapped;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end
