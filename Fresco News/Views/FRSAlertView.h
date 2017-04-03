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
@property (strong, nonatomic) UIButton *leftActionButton;
@property (strong, nonatomic) UIButton *rightCancelButton;
@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardTap;
@property CGFloat height;

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

/**
 This method is used to configure the title of the alert.
 
 @param title NSString The title of the alert.
 @param message NSString The message of the alert.
 @param actionTitle NSString The left action button title of the alert.
 @param cancelTitle NSString The right cancel button title of the alert.
 @param cancelTitleColor UIColor The right cancel button title color of the alert. Pass @"" to use the default cancel color.
 @param delegate id The delegate object which can confirm to the FRSAlertViewDelegate protocol.
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate;

/**
 This method is used to configure the title of the alert.

 @param title NSString The title of the alert.
 */
-(void)configureWithTitle:(NSString *)title;

/**
 This method is used to configure the message of the alert.
 
 @param message NSString The message of the alert.
 */
-(void)configureWithMessage:(NSString *)message;

/**
 This method is used to configure the message of the alert with any custom attributes.
 
 @param attributedMessage NSString The attributed message of the alert.
 */
-(void)configureWithAttributedMessage:(NSMutableAttributedString *)attributedMessage;

/**
 Adds a horizontal line view at specific Y position and for the full width of the alert view. 
 Generally used to draw a line above the action buttons.
 
 @param ypos CGFloat The Y position at which to place the horizontal line view.
 */
-(void)configureWithLineViewAtYposition:(CGFloat)ypos;

/**
 This method is used to configure both the action button titles of the alert.
 
 @param actionTitle NSString The left action button title of the alert.
 @param actionTitleColor UIColor The left action button title color of the alert.
 @param cancelTitle NSString The right cancel button title of the alert.
 @param cancelTitleColor UIColor The right cancel button title color of the alert.
 */
-(void)configureWithLeftActionTitle:(NSString *)actionTitle withColor:(UIColor *)actionTitleColor andRightCancelTitle:(NSString *)cancelTitle withColor:(UIColor *)cancelTitleColor;

/**
 Shows the alert on the window.
 */
- (void)show;

/**
 Dismisses the alert from the window.
 */
- (void)dismiss;

/**
 Animates out the alert from the window.
 */
- (void)animateOut;

/**
 Calculates and sets the frame of the alert view depending on the heights of title, message and action buttons. 
 
 If -(instancetype)initWithTitle withColor: andRightCancelTitle: withColor: is not used to create the alert, its the responsibility of the caller to calculate and set the height of the alert view by considering all its sub views.
 */
- (void)adjustFrame;

/**
 The default action method for the left action button. 
 Subclasses can override to perform any custom action. Make sure to call [super leftActionTapped].
 */
- (void)leftActionTapped;

/**
 The default action method for the right cancel button. 
 Subclasses can override to perform any custom action. Make sure to call [super rightCancelTapped].
 */
- (void)rightCancelTapped;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end
