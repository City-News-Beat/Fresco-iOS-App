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
#import <MapKit/MapKit.h>

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

@property (strong, nonatomic) UIView *actionLine;

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

@property (strong, nonatomic) UIButton *expandTOSButton;
@property (strong, nonatomic) UITextView *TOSTextView;
@property (strong, nonatomic) UIView *topLine;

@property (nonatomic) BOOL usernameTaken;
@property (nonatomic) BOOL emailTaken;
@property (strong, nonatomic) NSTimer *usernameTimer;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@property (strong, nonatomic) UIImageView *usernameCheckIV;
@property (strong, nonatomic) UILabel *usernameTakenLabel;
@property BOOL migrationAlertShouldShowPassword;

@property (strong, nonatomic) UIImageView *emailCheckIV;

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

-(void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *googleMaps = [UIAlertAction
                                 actionWithTitle:@"Open with Google Maps"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                     
                                     //https://www.google.com/maps/dir/40.7155488,+-74.0207971/Flatiron+School,+11+Broadway+%23260,+New+York,+NY+10004/
                                     
                                     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%f,%f",latitude,longitude]];
                                     if (![[UIApplication sharedApplication] canOpenURL:url]) {
                                         NSLog(@"Google Maps app is not installed");
                                         
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", latitude, longitude]]];
                                         
                                     } else {
                                         [[UIApplication sharedApplication] openURL:url];
                                     }
                                     
                                     
                                 }];
    
    UIAlertAction *appleMaps = [UIAlertAction
                                actionWithTitle:@"Open with Apple Maps"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [view dismissViewControllerAnimated:YES completion:nil];
                                    
                                    CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(latitude, longitude);
                                    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
                                    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
                                    
                                    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
                                    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
                                    
                                    [endingItem openInMapsWithLaunchOptions:launchOptions];
                                    
                                }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:googleMaps];
    [view addAction:appleMaps];
    [view addAction:cancel];
    
    [(id)self.delegate presentViewController:view animated:YES completion:nil];
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
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 33, [UIScreen mainScreen].bounds.size.width -80, 19)];
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


-(instancetype)initTOS {
    self = [super init];
    
    if (self) {
        
        if (![FRSAPIClient sharedClient].authenticatedUser) {
            return nil;
        }
        
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        self.alpha = 0;
        
        [self configureDarkOverlay];
        
        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"UPDATED TERMS";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        [[FRSAPIClient sharedClient] getTermsWithCompletion:^(id responseObject, NSError *error) {
            
            if (error || !responseObject) {
                return;
            }
            
            NSString *TOS = responseObject[@"terms"];
            TOS = [TOS stringByReplacingOccurrencesOfString:@"�" withString:@"\""];
            
            self.TOSTextView.text = TOS;
            
            [self addShadowAndClip];
            [self animateIn];
        }];
        
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TOS];
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle setLineSpacing:2];
//        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [TOS length])];
        
        self.TOSTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH)/2, 44, MESSAGE_WIDTH, 320)];
        self.TOSTextView.textColor = [UIColor frescoMediumTextColor];
        self.TOSTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
//        self.TOSTextView.attributedText = attributedString;
        self.TOSTextView.textAlignment = NSTextAlignmentLeft;
        self.TOSTextView.backgroundColor = [UIColor clearColor];
        self.TOSTextView.editable = NO;
        self.TOSTextView.delegate = self;
        [self addSubview:self.TOSTextView];
        
        self.expandTOSButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.expandTOSButton.tintColor = [UIColor blackColor];
        self.expandTOSButton.frame = CGRectMake(self.frame.size.width -24 -12, 10, 24, 24);
        [self.expandTOSButton setImage:[UIImage imageNamed:@"arrow-expand"] forState:UIControlStateNormal];
        [self.expandTOSButton addTarget:self action:@selector(expandTOS) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.expandTOSButton];
        
        /* Action Shadow */
        self.actionLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height -43.5, ALERT_WIDTH, 0.5)];
        self.actionLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.actionLine];
        
        self.topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 0.5)];
        self.topLine.alpha = 0;
        self.topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.topLine];
        
        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(14, self.TOSTextView.frame.origin.y + self.TOSTextView.frame.size.height, 54, 44);
        [self.actionButton setTitleColor:[UIColor frescoRedHeartColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];
        
        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 0, 44);
        [self.cancelButton addTarget:self action:@selector(acceptTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"ACCEPT" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 16, self.cancelButton.frame.origin.y, 49, 44)];
        [self addSubview:self.cancelButton];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - ALERT_WIDTH/2, [UIScreen mainScreen].bounds.size.height/2 - 408/2, ALERT_WIDTH, 408);
        self.actionLine.frame = CGRectMake(0, self.frame.size.height -43.5, ALERT_WIDTH, 0.5);
        
//        [self addShadowAndClip];
        //[self animateIn];
    }
    return self;
}

-(void)expandTOS {
    
//    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
    if ((IS_STANDARD_IPHONE_6_PLUS) || (IS_STANDARD_IPHONE_6)) {
        self.titleLabel.text = @"UPDATED TERMS OF SERVICE";
    }
    
    if (self.frame.size.width == ALERT_WIDTH) {
        self.frame = CGRectMake(16, 20, [UIScreen mainScreen].bounds.size.width -32, [UIScreen mainScreen].bounds.size.height -40);
        [self.expandTOSButton setImage:[UIImage imageNamed:@"arrow-compress"] forState:UIControlStateNormal];
    } else {
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - ALERT_WIDTH/2, [UIScreen mainScreen].bounds.size.height/2 - 408/2, ALERT_WIDTH, 408);
        [self.expandTOSButton setImage:[UIImage imageNamed:@"arrow-expand"] forState:UIControlStateNormal];
        self.titleLabel.text = @"UPDATED TERMS";
    }
    
    self.expandTOSButton.frame = CGRectMake(self.frame.size.width -24 -12, 10, 24, 24);
    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 44);
    self.TOSTextView.frame = CGRectMake((self.frame.size.width - (self.frame.size.width - 32))/2, 44, (self.frame.size.width - 32), self.frame.size.height -88);
    self.actionButton.frame = CGRectMake(14, self.frame.size.height -44, 54, 44);
    self.cancelButton.frame = CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width-16, self.actionButton.frame.origin.y, self.cancelButton.frame.size.width, 44);
    self.actionLine.frame = CGRectMake(0, self.frame.size.height -43.5, self.frame.size.width, 0.5);
    self.topLine.frame = CGRectMake(0, 44, self.frame.size.width, 0.5);
//    } completion:nil];

}

-(void)acceptTapped {
    
    [[FRSAPIClient sharedClient] acceptTermsWithCompletion:^(id responseObject, NSError *error) {
        if (!error) {
            [self dismiss];
        }
        else {
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
            [alert show];
        }
    }];
}

-(void)logoutTapped {
    [self.delegate logoutAlertAction];
    [self dismiss];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.TOSTextView) {
        if (scrollView.contentOffset.y >= 5) {
            self.topLine.alpha = 1;
        } else {
            self.topLine.alpha = 0;
        }
    }
}





-(instancetype)initNewStuffWithPasswordField:(BOOL)password {
    
    self = [super init];
    if (self){
        
        self.height = 0;
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        
        [self configureDarkOverlay];
        
        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"NEW STUFF!";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];
        
        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH)/2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        

        self.messageLabel.text = [NSString stringWithFormat:@"We’ve added a ton of new\nfeatures for Fresco 3.0. You can now %@, %@, and %@ on galleries, %@ your friends and favorite photographers, and see more about assignments.\n\nTo start, we’ll need you to choose a username. You’ll be able to change it later on.", @"like", @"repost", @"comment", @"follow"];
        
        NSRange range1 = [self.messageLabel.text rangeOfString:@"like"];
        NSRange range2 = [self.messageLabel.text rangeOfString:@"repost"];
        NSRange range3 = [self.messageLabel.text rangeOfString:@"comment"];
        NSRange range4 = [self.messageLabel.text rangeOfString:@"follow"];

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.messageLabel.text];
        
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]}
                                range:range2];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]}
                                range:range3];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]}
                                range:range4];
        
        
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:attributedText.string];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedText.string length])];
        
        
        self.messageLabel.attributedText = attributedText;

        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];
        
        /* Action Shadow */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 336, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];
        
        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(16, 337, 54, 44);
        [self.actionButton setTitleColor:[UIColor frescoRedHeartColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];
        
        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 37, 44);
        [self.cancelButton addTarget:self action:@selector(updateUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"DONE" forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];
        
        UIView *usernameContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 248, self.frame.size.width, 44)];
        [self addSubview:usernameContainer];
        
        UIView *usernameTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        usernameTopLine.backgroundColor = [UIColor frescoShadowColor];
        [usernameContainer addSubview:usernameTopLine];
        
        UIView *emailContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 292, self.frame.size.width, 44)];
        [self addSubview:emailContainer];
        
        UIView *emailTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        emailTopLine.backgroundColor = [UIColor frescoShadowColor];
        [emailContainer addSubview:emailTopLine];
        
        self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16+16), 20)];
        [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.usernameTextField.tag = 1;
        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usernameTextField.placeholder = @"@username";
        self.usernameTextField.tintColor = [UIColor frescoBlueColor];
        self.usernameTextField.delegate = self;
        self.usernameTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.usernameTextField.textColor = [UIColor frescoDarkTextColor];
        [usernameContainer addSubview:self.usernameTextField];
        
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16+16), 20)];
        [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.emailTextField.tag = 2;
        self.emailTextField.placeholder = @"Email address";
        self.emailTextField.tintColor = [UIColor frescoBlueColor];
        self.emailTextField.delegate = self;
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.textColor = [UIColor frescoDarkTextColor];
        self.emailTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        [emailContainer addSubview:self.emailTextField];
        
        self.emailCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.emailCheckIV.frame = CGRectMake(emailContainer.frame.size.width -24 -6, 10, 24, 24);
        self.emailCheckIV.alpha = 0;
        [emailContainer addSubview:self.emailCheckIV];
        
        self.usernameCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.usernameCheckIV.frame = CGRectMake(usernameContainer.frame.size.width -24 -6, 10, 24, 24);
        self.usernameCheckIV.alpha = 0;
        [usernameContainer addSubview:self.usernameCheckIV];
        
        self.usernameTakenLabel = [[UILabel alloc] initWithFrame:CGRectMake(-44 -6, 5, 44, 17)];
        self.usernameTakenLabel.text = @"TAKEN";
        self.usernameTakenLabel.alpha = 0;
        self.usernameTakenLabel.textColor = [UIColor frescoRedHeartColor];
        self.usernameTakenLabel.font = [UIFont notaBoldWithSize:15];
        [self.usernameCheckIV addSubview:self.usernameTakenLabel];
        
        if (password) {
            
            self.migrationAlertShouldShowPassword = YES;
            
            UIView *passwordContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 292+44, self.frame.size.width, 44)];
            [self addSubview:passwordContainer];
            
            UIView *passwordTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
            passwordTopLine.backgroundColor = [UIColor frescoShadowColor];
            [passwordContainer addSubview:passwordTopLine];
            
            self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16+16), 20)];
            [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            self.passwordTextField.tag = 3;
            self.passwordTextField.placeholder = @"Password";
            self.passwordTextField.tintColor = [UIColor frescoBlueColor];
            self.passwordTextField.delegate = self;
            self.passwordTextField.keyboardType = UIKeyboardTypeDefault;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.textColor = [UIColor frescoDarkTextColor];
            self.passwordTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            [passwordContainer addSubview:self.passwordTextField];
            
            self.height += 44;
        }

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:tap];

        self.height += 380;
        
        NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width  - ALERT_WIDTH)/2;
        NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height)/2;
        
        self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, self.height - 44, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
        self.actionButton.frame = CGRectMake(self.actionButton.frame.origin.x, self.height - 44, self.actionButton.frame.size.width, self.actionButton.frame.size.height);
        line.frame = CGRectMake(line.frame.origin.x, self.height - 44, line.frame.size.width, line.frame.size.height);
        self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
        
        [self addShadowAndClip];
        
        [self animateIn];
        
    }
    return self;
    
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if (self.migrationAlertShouldShowPassword) {
            self.transform = CGAffineTransformMakeTranslation(0, -100);
        } else {
            self.transform = CGAffineTransformMakeTranslation(0, -80);
        }
        
    } completion:nil];
    
    if (self.emailTextField.isEditing) {
        self.emailCheckIV.alpha = 0;
    }
    
    if (textField.tag == 1) {
        [self startUsernameTimer];
        if ([textField.text isEqualToString:@""]){
            textField.text = @"@";
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField   {
    
    if (textField == self.usernameTextField) {
        
        if ([textField.text isEqualToString:@"@"]) {
            textField.text = @"";
        }
    }
    
    
    if ((textField == self.emailTextField) && ([self isValidEmail:self.emailTextField.text])) {
        [self checkEmail];
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        
    } completion:nil];
}

-(void)textFieldDidChange:(UITextField *)textField {
    if ((textField == self.emailTextField) && ([self isValidEmail:self.emailTextField.text])) {
        [self checkEmail];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    if (self.usernameTextField.isEditing) {
        [self startUsernameTimer];
        
        if ([[self.usernameTextField.text substringFromIndex:1] isEqualToString:@""]){
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:NO success:NO];
        }
    }
    
    [self checkCreateAccountButtonState];
    
    
    if (textField.tag == 1) {
        
        if ([string containsString:@" "]) {
            return NO;
        }
        
        if (textField.text.length == 1 && [string isEqualToString:@""]) {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 20;
    }
    
    return YES;
}

-(void)tap {
    [self resignFirstResponder];
    [self endEditing:YES];
}


-(void)updateUserInfo {

    [self checkEmail];
    
    
    
//    [self dismiss];
}


-(void)checkEmail {
    
    [[FRSAPIClient sharedClient] checkEmail:self.emailTextField.text completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            self.emailTaken = YES;
            [self shouldShowEmailError:YES];
        } else {
            self.emailTaken = NO;
            [self shouldShowEmailError:NO];
        }
        
        [self checkCreateAccountButtonState];
    }];
}

-(void)shouldShowEmailError:(BOOL)error {
    
    NSLog(@"EMAIL ERROR: %d", error);
    
    if (error) {
        self.emailCheckIV.alpha = 1;
    } else {
        self.emailCheckIV.alpha = 0;
    }
}

-(void)startUsernameTimer {
    if (!self.usernameTimer) {
        NSLog(@"TIMER STARTED");
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(usernameTimerFired) userInfo:nil repeats:YES];
    }
}


-(void)stopUsernameTimer {
    if ([self.usernameTimer isValid]) {
        NSLog(@"TIMER ENDED");
        [self.usernameTimer invalidate];
    }
    
    self.usernameTimer = nil;
}


-(void)usernameTimerFired {
    NSLog(@"TIMER FIRED");
    
    if ([self.usernameTextField.text isEqualToString:@""]) {
        self.usernameCheckIV.alpha = 0;
        self.usernameTakenLabel.alpha = 0;
        [self stopUsernameTimer];
        return;
    }
    
    // Check for emoji and error
    if ([self stringContainsEmoji:[self.usernameTextField.text substringFromIndex:1]]){
        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
        return;
    }
    
    if (self.usernameTextField.isEditing && (![self stringContainsEmoji:[self.usernameTextField.text substringFromIndex:1]])) {
        
        if ((![[self.usernameTextField.text substringFromIndex:1] isEqualToString:@""])) {
            
            [[FRSAPIClient sharedClient] checkUsername:[self.usernameTextField.text substringFromIndex:1] completion:^(id responseObject, NSError *error) {
                
                //Return if no internet
                if (error.code == -1009) {
                    
                    return;
                }
                
                NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                NSInteger responseCode = response.statusCode;
                NSLog(@"TIMER CODE: %ld", responseCode);
                
                if (responseCode == 404) { //
                    [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:YES];
                    self.usernameTaken = NO;
                    [self stopUsernameTimer];
                    [self checkCreateAccountButtonState];
                    return;
                } else {
                    [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
                    self.usernameTaken = YES;
                    [self stopUsernameTimer];
                    [self checkCreateAccountButtonState];
                }
            }];
        }
    }
}

-(void)animateUsernameCheckImageView:(UIImageView *)imageView animateIn:(BOOL)animateIn success:(BOOL)success {

    NSLog(@"TIMER SHOW: %d", success);
    
    if(success) {
        self.usernameCheckIV.image = [UIImage imageNamed:@""];
        self.usernameTakenLabel.alpha = 0;
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
        self.usernameTakenLabel.alpha = 1;
    }
    
    if (animateIn) {
        if (self.usernameCheckIV.alpha == 0) {
            
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.usernameCheckIV.alpha = 0;
            self.usernameCheckIV.alpha = 1;
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1, 1);
        }
    } else {
        
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
        self.usernameCheckIV.alpha = 0;
    }
}


-(BOOL)stringContainsEmoji:(NSString *)string {
    
    if ([string isEqualToString:@""]) {
        return NO;
    }
    
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

-(void)checkCreateAccountButtonState {
    UIControlState controlState;
    
    if (([self.usernameTextField.text length] > 0) && ([self.emailTextField.text length] > 0)) {
        
        if ([self isValidUsername:[self.usernameTextField.text substringFromIndex:1]] && [self isValidEmail:self.emailTextField.text] && (!self.emailTaken) && (!self.usernameTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
}

-(BOOL)isValidUsername:(NSString *)username {
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validUsernameChars];
    NSCharacterSet *disallowedSet = [allowedSet invertedSet];
    return ([username rangeOfCharacterFromSet:disallowedSet].location == NSNotFound);
}

-(BOOL)isValidEmail:(NSString *)emailString {
    
    if([emailString length] == 0) {
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

-(void)toggleCreateAccountButtonTitleColorToState:(UIControlState )controlState {
    if (controlState == UIControlStateNormal){
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
    } else {
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[[UIColor frescoBlueColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        self.cancelButton.enabled = YES;
    }
    
}



@end
