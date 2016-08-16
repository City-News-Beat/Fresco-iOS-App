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

#import <Contacts/Contacts.h>

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@interface FRSAlertView ()


/* Reusable Alert Properties */
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *buttonShadow;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *actionButton;

@property CGFloat height;


/* Permissions Alert Properties */
@property (nonatomic) BOOL notificationsEnabled;
@property (nonatomic) BOOL locationEnabled;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) UIButton *locationButtonDisabled;
@property (strong, nonatomic) UIButton *notificationButton;
@property (strong, nonatomic) UIButton *notificationButtonDisabled;

@property (strong, nonatomic) UIButton *permissionsDoneButton;
@property (strong, nonatomic) UIButton *permissionsLaterButton;


@end


@implementation FRSAlertView

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate {
    self = [super init];
    if (self){
        
        self.delegate = delegate;
        
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        
        [self configureDarkOverlay];
        
        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = title;
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH)/2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
        
        self.messageLabel.attributedText = attributedString ;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];
        
        /* Action Shadow */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];
        
        if ([cancelTitle  isEqual: @""]){
            /* Single Action Button */
            self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.actionButton addTarget:self action:@selector(actionTapped) forControlEvents:UIControlEventTouchUpInside];
            self.actionButton.frame = CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, ALERT_WIDTH, 44);
            [self.actionButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
            [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
            [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
            [self addSubview:self.actionButton];
        } else {
            /* Left Action */
            self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.actionButton addTarget:self action:@selector(actionTapped) forControlEvents:UIControlEventTouchUpInside];
            self.actionButton.frame = CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 85, 44);
            [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
            [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
            [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
            [self addSubview:self.actionButton];
            
            /* Right Action */
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 101, 44);
            [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
            [self.cancelButton setTitleColor:cancelTitleColor forState:UIControlStateNormal];
            [self.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
            [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
            [self.cancelButton sizeToFit];
            [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
            [self addSubview:self.cancelButton];
            
        }
        [self adjustFrame];
        [self addShadowAndClip];
        
        [self animateIn];
        
    }
    self.delegate = delegate;
    return self;
}

-(void)show {
    /* keyWindow places the view above all. Add overlay view first, and then alertView*/
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.inputViewController.view endEditing:YES];
    
}

-(void)adjustFrame {
    self.height = self.actionButton.frame.size.height + self.messageLabel.frame.size.height + self.titleLabel.frame.size.height + 15;
    
    //UIViewController* vc = (UIViewController *)self.delegate;
    
    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width  - ALERT_WIDTH)/2;
    NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height)/2;
    
    self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
}

-(void)addShadowAndClip {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.1;
    self.layer.cornerRadius = 2;
}


-(void)cancelTapped {
    [self animateOut];
    
    if (self.delegate) {
        [self.delegate didPressButtonAtIndex:1];
    }
}

-(void)actionTapped {
    [self animateOut];
    
    if (self.delegate) {
        [self.delegate didPressButtonAtIndex:0];
    }
}

-(void)settingsTapped {
    [self animateOut];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


-(void)animateIn {
    
    /* Set default state before animating in */
    self.transform = CGAffineTransformMakeScale(1.175, 1.175);
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 1;
                         self.titleLabel.alpha = 1;
                         self.cancelButton.alpha = 1;
                         self.actionButton.alpha = 1;
                         self.overlayView.alpha = 0.26;
                         self.transform = CGAffineTransformMakeScale(1, 1);
                         
                     } completion:nil];
}

-(void)animateOut {
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 0;
                         self.titleLabel.alpha = 0;
                         self.cancelButton.alpha = 0;
                         self.actionButton.alpha = 0;
                         self.overlayView.alpha = 0;
                         self.transform = CGAffineTransformMakeScale(0.9, 0.9);
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

-(void)configureDarkOverlay {
    /* Dark Overlay */
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    [self addSubview:(self.overlayView)];
}

#pragma mark - Custom Alerts

-(instancetype)initPermissionsAlert {
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];

        
        NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH)/2;
        NSInteger yOrigin = (([UIScreen mainScreen].bounds.size.height - 334)/2);
        self.frame = CGRectMake(xOrigin, yOrigin - 20, ALERT_WIDTH, 334);
        
        [self configureDarkOverlay];

        [self checkNotificationStatus];
        [self checkLocationStatus];
        
        [self configureRequestButtonsForPermissions];
        
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        title.font = [UIFont notaBoldWithSize:17];
        title.text = @"HOLD UP";
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor frescoDarkTextColor];
        [self addSubview:title];
        
        UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 44, 238, 80)];
        subTitle.text = @"We need your permission for a few things, so we can verify your submissions and notify you about nearby assignments and news.";
        subTitle.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        subTitle.numberOfLines = 4;
        subTitle.textAlignment = NSTextAlignmentCenter;
        subTitle.textColor = [UIColor frescoMediumTextColor];
        [self addSubview:subTitle];
        
        UITextView *locationTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 192+44-10, ALERT_WIDTH, 42)];
        locationTextView.userInteractionEnabled  = NO;
        locationTextView.clipsToBounds = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = -2;
        paragraphStyle.minimumLineHeight = -100;
        
        locationTextView.attributedText = [[NSAttributedString alloc] initWithString:@"Your location is only shared when you \n post a gallery to Fresco. In all other cases \n your location is fully anonymous."
                                                                          attributes: @{NSParagraphStyleAttributeName : paragraphStyle,
                                                                                        NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightLight]}];
        
        locationTextView.textAlignment = NSTextAlignmentCenter;
        locationTextView.textColor = [UIColor frescoMediumTextColor];
        locationTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:locationTextView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 290, self.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor frescoShadowColor];
        [self addSubview:line];
        
        [self configureActionButtonsForPermissions];
        
        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

-(void)configureRequestButtonsForPermissions {
    
    if (self.locationEnabled) {
        [self configureLocationButtonEnabled:YES];
        
    } else {
        [self configureLocationButtonEnabled:NO];
    }
    
    if (self.notificationsEnabled) {
        [self configureNotificationButtonEnabled:YES];
    
    } else {
        [self configureNotificationButtonEnabled:NO];
    }
}

-(void)configureActionButtonsForPermissions {
    
    self.permissionsLaterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.permissionsLaterButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    self.permissionsLaterButton.frame = CGRectMake(0, 290, 104, 44);
    [self.permissionsLaterButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [self.permissionsLaterButton setTitle:@"ASK LATER" forState:UIControlStateNormal];
    [self.permissionsLaterButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self addSubview:self.permissionsLaterButton];
    
    self.permissionsDoneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.permissionsDoneButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    self.permissionsDoneButton.frame = CGRectMake(185, 290, 104, 44);
    [self.permissionsDoneButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [self.permissionsDoneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [self.permissionsDoneButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    self.permissionsDoneButton.enabled = NO;
    
    if (self.notificationsEnabled && self.locationEnabled) {
        [self.permissionsLaterButton removeFromSuperview];
        self.permissionsDoneButton.enabled = YES;
        [self.permissionsDoneButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.permissionsDoneButton.frame = CGRectMake(0, 290, self.frame.size.width, 44);
    }
    
    [self addSubview:self.permissionsDoneButton];
}

-(void)configureNotificationButtonEnabled:(BOOL)enabled {
    
    if (enabled) {
        self.notificationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.notificationButton.frame = CGRectMake(0, 136+44, self.frame.size.width, 44);
        [self.notificationButton setTitle:@"NOTIFICATIONS ENABLED" forState:UIControlStateNormal];
        [self.notificationButton setTintColor:[UIColor frescoOrangeColor]];
        [self.notificationButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        self.notificationButton.userInteractionEnabled = NO;
        
        UIImageView *notificationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bell-selected"]];
        [self.notificationButton setImage:notificationImageView.image forState:UIControlStateNormal];
        self.notificationButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23.5, 0, 23.5);
        self.notificationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [self addSubview:self.notificationButton];
        
    } else {
        self.notificationButtonDisabled = [UIButton buttonWithType:UIButtonTypeSystem];
        self.notificationButtonDisabled.frame = CGRectMake(0, 136+44, self.frame.size.width, 44);
        [self.notificationButtonDisabled setTitle:@"ENABLE NOTIFICATIONS" forState:UIControlStateNormal];
        [self.notificationButtonDisabled setTintColor:[UIColor frescoDarkTextColor]];
        [self.notificationButtonDisabled.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.notificationButtonDisabled addTarget:self action:@selector(requestNotifications) forControlEvents:UIControlEventTouchDown];
        
        UIImageView *notificationImageViewDisabled = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bell"]];
        [self.notificationButtonDisabled setImage:notificationImageViewDisabled.image forState:UIControlStateNormal];
        self.notificationButtonDisabled.imageEdgeInsets = UIEdgeInsetsMake(0, -28, 0, 28);
        self.notificationButtonDisabled.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [self addSubview:self.notificationButtonDisabled];
    }
}

-(void)configureLocationButtonEnabled:(BOOL)enabled {
    
    if (enabled) {
        self.locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.locationButton.frame = CGRectMake(0, 136, self.frame.size.width, 44);
        [self.locationButton setTitle:@"LOCATION ENABLED" forState:UIControlStateNormal];
        [self.locationButton setTintColor:[UIColor frescoOrangeColor]];
        [self.locationButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        self.locationButton.userInteractionEnabled = NO;
        
        UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-marker-selected"]];
        [self.locationButton setImage:locationImageView.image forState:UIControlStateNormal];
        self.locationButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 40);
        self.locationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [self addSubview:self.locationButton];
        
    } else {
        self.locationButtonDisabled = [UIButton buttonWithType:UIButtonTypeSystem];
        self.locationButtonDisabled.frame = CGRectMake(0, 136, self.frame.size.width, 44);
        [self.locationButtonDisabled setTitle:@"ENABLE LOCATION" forState:UIControlStateNormal];
        [self.locationButtonDisabled setTintColor:[UIColor frescoDarkTextColor]];
        [self.locationButtonDisabled.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.locationButtonDisabled addTarget:self action:@selector(requestLocation) forControlEvents:UIControlEventTouchDown];
        
        UIImageView *locationImageViewDisabled = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-marker"]];
        [self.locationButtonDisabled setImage:locationImageViewDisabled.image forState:UIControlStateNormal];
        self.locationButtonDisabled.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 45);
        self.locationButtonDisabled.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [self addSubview:self.locationButtonDisabled];
    }
}

-(void)checkLocationStatus {
    self.locationEnabled = NO;
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        self.locationEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"location-enabled"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"location-enabled"];
    }

}

-(void)checkNotificationStatus {
    self.notificationsEnabled = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            self.notificationsEnabled = NO;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notifications-enabled"];
        } else {
            self.notificationsEnabled = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications-enabled"];
        }
    }
}

-(void)requestLocation {
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"LocationRequested"]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LocationRequested"];
}

-(void)requestNotifications {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NotificationsRequested"]) {
        UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotificationsRequested"];
}

-(void)appWillBecomeActive:(NSNotification *)notification {

    [self checkLocationStatus];
    [self checkNotificationStatus];
    
    if ((self.locationEnabled) && (self.locationButton == nil)) {
        [self.locationButton removeFromSuperview]; //Remove from superview to avoid duplicates
        [self.locationButtonDisabled removeFromSuperview];
        [self configureLocationButtonEnabled:YES];
    }
    
    if  ((self.notificationsEnabled) && (self.notificationButton == nil)){
        [self.notificationButton removeFromSuperview];
        [self.notificationButtonDisabled removeFromSuperview];
        [self configureNotificationButtonEnabled:YES];
    }
    
    if (self.notificationsEnabled && self.locationEnabled) {
        [self.permissionsDoneButton removeFromSuperview];
        [self.permissionsLaterButton removeFromSuperview];
        
        [self configureActionButtonsForPermissions];
    }
}

-(void)applicationWillEnterForeground:(NSNotification *)notification {
        
    [self checkLocationStatus];
    [self checkNotificationStatus];
    
    if ((self.locationEnabled) && (self.locationButton == nil)) {
        [self.locationButton removeFromSuperview]; //Remove from superview to avoid duplicates
        [self.locationButtonDisabled removeFromSuperview];
        [self configureLocationButtonEnabled:YES];
    }
    
    if  ((self.notificationsEnabled) && (self.notificationButton == nil)){
        [self.notificationButton removeFromSuperview];
        [self.notificationButtonDisabled removeFromSuperview];
        [self configureNotificationButtonEnabled:YES];
    }
    
    if (self.notificationsEnabled && self.locationEnabled) {
        [self.permissionsDoneButton removeFromSuperview];
        [self.permissionsLaterButton removeFromSuperview];
        
        [self configureActionButtonsForPermissions];
    }
}

-(instancetype)initFindFriendsAlert {
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
        self.titleLabel.text = @"NOT SURE WHO TO FOLLOW?";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH)/2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Connect your address book to find your friends on Fresco."];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Connect your address book to find your friends on Fresco." length])];
        
        self.messageLabel.attributedText = attributedString ;
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
        self.actionButton.frame = CGRectMake(14, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 85, 44);
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"NO THANKS" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];
        
        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 0, 44);
        [self.cancelButton addTarget:self action:@selector(requestContacts) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"FIND FRIENDS" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - ALERT_WIDTH/2, [UIScreen mainScreen].bounds.size.height/2 - 70, ALERT_WIDTH, 140);
        
        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

-(void)requestContacts {
    
//    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted || status == CNAuthorizationStatusNotDetermined) {
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

//        return;
//    }
}


-(instancetype)initNoConnectionAlert {
    self = [super init];
    
    if (self) {
        
        NSString *message = @"Please check your internet connection.";
        
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        
        [self configureDarkOverlay];
        
        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"NO CONNECTION";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH)/2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
        
        self.messageLabel.attributedText = attributedString ;
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
        [self.actionButton addTarget:self action:@selector(settingsTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 85, 44);
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"SETTINGS" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];
        
        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 101, 44);
        [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"OK" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];
        
        [self adjustFrame];
        [self addShadowAndClip];
        
        [self animateIn];
        
    
    }
    
    return self;
}


-(instancetype)initSignUpAlert {
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
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH)/2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Are you sure you don’t want to sign up for Fresco?"];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Are you sure you don’t want to sign up for Fresco?" length])];
        
        self.messageLabel.attributedText = attributedString ;
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
        [self.cancelButton setTitleColor:[UIColor frescoRedHeartColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"DELETE" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - ALERT_WIDTH/2, [UIScreen mainScreen].bounds.size.height/2 - 70, ALERT_WIDTH, 140);
        
        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

-(void)returnToPreviousViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"returnToPreviousViewController" object:self];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"facebook-name"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebook-connected"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"twitter-handle"];
}

-(void)dismiss {
    [self animateOut];
    
//    if (self.delegate) {
//        [self.delegate didPressButtonAtIndex:1];
//    }
}

-(instancetype)initNoConnectionBannerWithBackButton:(BOOL)backButton {
    
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
        self.backgroundColor = [UIColor frescoRedHeartColor];
        
        
        NSString *title = @"";
        
        if (IS_IPHONE_5) {
            title = @"UNABLE TO CONNECT";
        } else if (IS_IPHONE_6) {
            title = @"UNABLE TO CONNECT. CHECK SIGNAL";
        } else if (IS_IPHONE_6_PLUS) {
            title = @"UNABLE TO CONNECT. CHECK YOUR SIGNAL";
        }
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 35, [UIScreen mainScreen].bounds.size.width -80, 19)];
        label.font = [UIFont notaBoldWithSize:17];
        label.textColor = [UIColor whiteColor];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        
        if (backButton) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [backButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
            backButton.frame = CGRectMake(12, 30, 24, 24);
            backButton.tintColor = [UIColor whiteColor];
            [self addSubview:backButton];
        }

        [UIView animateWithDuration:0.3 delay:2.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0;
        } completion:nil];
    }
    return self;
}


@end
