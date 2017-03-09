//
//  FRSModerationAlertView.h
//  Fresco
//
//  Created by Maurice Wu on 3/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRSModerationAlertView;

@protocol FRSModerationAlertViewDelegate <NSObject>

@required
@optional
- (void)didPressButton:(FRSModerationAlertView *)alertView atIndex:(NSInteger)index;
- (void)logoutAlertAction;
- (void)reportGalleryAlertAction;
- (void)reportUserAlertAction;
- (void)blockUserAlertAction;
- (void)didPressRadioButtonAtIndex:(NSInteger)index;

@end

@interface FRSModerationAlertView : UIView

@property (strong, nonatomic) UITextView *textView;

@property (weak, nonatomic) NSObject<FRSModerationAlertViewDelegate> *delegate;

- (instancetype)initUserReportWithUsername:(NSString *)username delegate:(id)delegate;
- (instancetype)initGalleryReportDelegate:(id)delegate;
- (void)show;

@end
