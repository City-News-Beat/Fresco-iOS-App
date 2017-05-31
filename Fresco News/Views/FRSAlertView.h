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
- (void)segueToTipsAction;

@end

@interface FRSAlertView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *leftActionButton;
@property (strong, nonatomic) UIButton *rightCancelButton;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIView *line;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardTap;
@property CGFloat height;

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

/**
 This method is used to configure the title of the alert.
 
 @param title NSString The title of the alert.
 @param message NSString The message of the alert.
 @param actionTitle NSString The left action button title of the alert.
 @param cancelTitle NSString The right cancel button title of the alert. Pass @""(empty string) to omit this button and to have only one action button on the alert.
 @param cancelTitleColor UIColor The right cancel button title color of the alert. Pass nil to use the default color for right cancel title. N/A if cancelTitle is @""(empty string)
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
 @param actionTitleColor UIColor The left action button title color of the alert. Pass nil to use the default color(frescoDarkTextColor) for left action title.
 @param cancelTitle NSString The right cancel button title of the alert.
 @param cancelTitleColor UIColor The right cancel button title color of the alert. Pass nil to use the default color(frescoBlueColor) for right cancel title.
 */
-(void)configureWithLeftActionTitle:(NSString *)actionTitle withColor:(UIColor *)actionTitleColor andRightCancelTitle:(NSString *)cancelTitle withColor:(UIColor *)cancelTitleColor;

/**
 Shows the alert on the window.
 */
- (void)show;

/**
 Dismisses the alert from the window with animation.
 */
- (void)dismiss;

/**
 Calculates and sets the frame of the alert view depending on the heights of title, message and action buttons only. Subclasses using only these basic element can call this method at the end, after setting values to the elements.
 
 If -(instancetype)initWithTitle withColor: andRightCancelTitle: withColor: is not used to create the alert, its the responsibility of the caller to calculate and set the height of the alert view by considering all its sub views.
 */
- (void)adjustFrame;

/**
 The default action method for the left action button. Also dismisses the alert.
 Subclasses can override to perform any custom action. Make sure to call [super leftActionTapped].
 */
- (void)leftActionTapped;

/**
 The default action method for the right cancel button. Also dismisses the alert.
 Subclasses can override to perform any custom action. Make sure to call [super rightCancelTapped].
 */
- (void)rightCancelTapped;

/**
 Adjusts the frame when the device is rotated. This is used in the transparent alert when paginating tips in the CameraVC.
 */
- (void)adjustFrameForRotatedState;

@property BOOL isRotated;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end
