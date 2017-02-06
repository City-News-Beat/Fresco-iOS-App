//
//  FRSAlertView.h
//  Fresco
//
//  Created by Omar Elfanek on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol FRSAlertViewDelegate <NSObject>

@required
@optional
- (void)didPressButtonAtIndex:(NSInteger)index;
- (void)logoutAlertAction;
- (void)reportGalleryAlertAction;
- (void)reportUserAlertAction;
- (void)blockUserAlertAction;
- (void)didPressRadioButtonAtIndex:(NSInteger)index;

@end

@interface FRSAlertView : UIView <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate;

- (void)show;
- (void)dismiss;

- (instancetype)initPermissionsAlert:(id)delegate;
- (instancetype)initFindFriendsAlert;
- (instancetype)initSignUpAlert;
- (instancetype)initNoConnectionAlert;
- (instancetype)initNoConnectionBannerWithBackButton:(BOOL)backButton;
- (instancetype)initTOS;
- (instancetype)initNewStuffWithPasswordField:(BOOL)password;
- (instancetype)initUserReportWithUsername:(NSString *)username delegate:(id)delegate;
- (instancetype)initGalleryReportDelegate:(id)delegate;

- (void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIButton *actionButton;

@end
