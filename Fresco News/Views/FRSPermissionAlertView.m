//
//  FRSPermissionAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 2/26/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSPermissionAlertView.h"
#import "UIFont+Fresco.h"



@interface FRSPermissionAlertView()

@property (nonatomic) BOOL notificationsEnabled;
@property (nonatomic) BOOL locationEnabled;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) UIButton *locationButtonDisabled;
@property (strong, nonatomic) UIButton *notificationButton;
@property (strong, nonatomic) UIButton *notificationButtonDisabled;
@property (strong, nonatomic) UIButton *permissionsDoneButton;
@property (strong, nonatomic) UIButton *permissionsLaterButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation FRSPermissionAlertView

- (instancetype)initWithLocationManagerDelegate:(id)delegate {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
        NSInteger yOrigin = (([UIScreen mainScreen].bounds.size.height - 334) / 2);
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
        
        UITextView *locationTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 192 + 44 - 10, ALERT_WIDTH, 42)];
        locationTextView.userInteractionEnabled = NO;
        locationTextView.clipsToBounds = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = -2;
        paragraphStyle.minimumLineHeight = -100;
        
        locationTextView.attributedText = [[NSAttributedString alloc] initWithString:@"Your location is only shared when you \n post a gallery to Fresco. In all other cases \n your location is fully anonymous."
                                                                          attributes:@{ NSParagraphStyleAttributeName : paragraphStyle,
                                                                                        NSFontAttributeName : [UIFont systemFontOfSize:12 weight:UIFontWeightLight] }];
        
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
        
        self.locationManager.delegate = delegate;
    }
    return self;
}

- (void)checkLocationStatus {
    self.locationEnabled = NO;
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        self.locationEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:locationEnabled];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:locationEnabled];
    }
}

- (void)checkNotificationStatus {
    self.notificationsEnabled = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            self.notificationsEnabled = NO;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:settingsUserNotificationToggle];
        } else {
            self.notificationsEnabled = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:settingsUserNotificationToggle];
        }
    }
}

- (void)configureRequestButtonsForPermissions {
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

- (void)configureActionButtonsForPermissions {
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

- (void)configureNotificationButtonEnabled:(BOOL)enabled {
    if (enabled) {
        self.notificationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.notificationButton.frame = CGRectMake(0, 136 + 44, self.frame.size.width, 44);
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
        self.notificationButtonDisabled.frame = CGRectMake(0, 136 + 44, self.frame.size.width, 44);
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

- (void)configureLocationButtonEnabled:(BOOL)enabled {
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

- (void)requestLocation {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LocationRequested"]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LocationRequested"];
}

- (void)requestNotifications {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NotificationsRequested"]) {
        UIUserNotificationType types = (UIUserNotificationType)(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotificationsRequested"];
}

- (void)appWillBecomeActive:(NSNotification *)notification {
    
    [self checkLocationStatus];
    [self checkNotificationStatus];
    
    if ((self.locationEnabled) && (self.locationButton == nil)) {
        [self.locationButton removeFromSuperview]; //Remove from superview to avoid duplicates
        [self.locationButtonDisabled removeFromSuperview];
        [self configureLocationButtonEnabled:YES];
    }
    
    if ((self.notificationsEnabled) && (self.notificationButton == nil)) {
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

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self checkLocationStatus];
    [self checkNotificationStatus];
    
    if ((self.locationEnabled) && (self.locationButton == nil)) {
        [self.locationButton removeFromSuperview]; //Remove from superview to avoid duplicates
        [self.locationButtonDisabled removeFromSuperview];
        [self configureLocationButtonEnabled:YES];
    }
    
    if ((self.notificationsEnabled) && (self.notificationButton == nil)) {
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

@end
