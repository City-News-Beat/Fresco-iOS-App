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

@interface FRSAlertView : UIView <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate;

- (void)show;
- (void)dismiss;

- (instancetype)initPermissionsAlert:(id)delegate;
- (instancetype)initFindFriendsAlert;
- (instancetype)initNoConnectionBannerWithBackButton:(BOOL)backButton;
- (instancetype)initTOS;
- (instancetype)initNewStuffWithPasswordField:(BOOL)password;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIButton *actionButton;

@end
