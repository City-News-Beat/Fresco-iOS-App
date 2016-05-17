//
//  FRSAlertView.h
//  Fresco
//
//  Created by Omar Elfanek on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSAlertViewDelegate <NSObject>

-(void)didPressButtonAtIndex:(NSInteger)index;

@end


@interface FRSAlertView : UIView

@property (weak, nonatomic) NSObject <FRSAlertViewDelegate> *delegate;

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate;

-(void)show;
-(void)dismiss;

-(instancetype)initPermissionsAlert;

-(instancetype)initFindFriendsAlert;

-(instancetype)initSignUpAlert;

@end
