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

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@interface FRSAlertView ()

@property (strong, nonatomic) UIView* overlayView;
@property (strong, nonatomic) UIView* buttonShadow;

@property (strong, nonatomic) UILabel* titleLabel;
@property (strong, nonatomic) UILabel* messageLabel;

@property (strong, nonatomic) UIButton* cancelButton;
@property (strong, nonatomic) UIButton* actionButton;

@property CGFloat height;


@end

@implementation FRSAlertView

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle delegate:(id)delegate{
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
            [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
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
    return self;
}

-(void)show{
    /* keyWindow places the view above all. Add overlay view first, and then alertView*/
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}

-(void)adjustFrame{
    self.height = self.actionButton.frame.size.height + self.messageLabel.frame.size.height + self.titleLabel.frame.size.height + 15;
    
    UIViewController* vc = (UIViewController *)self.delegate;
    
    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH)/2;
    NSInteger yOrigin = (vc.view.frame.size.height - self.height)/2 + self.height/2;
    self.frame = CGRectMake(xOrigin, yOrigin - 20, ALERT_WIDTH, self.height);
    
}

-(void)addShadowAndClip{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.1;
    self.layer.cornerRadius = 2;
}


-(void)cancelTapped{
    [self animateOut];
}

-(void)actionTapped{
    [self animateOut];
}


-(void)animateIn{
    
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

-(void)animateOut{
    
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

-(void)configureDarkOverlay{
    /* Dark Overlay */
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    [self addSubview:(self.overlayView)];
}

#pragma mark - Custom Alerts

-(instancetype)initPermissionsAlert{
    self = [super init];
    
    if (self){
        [self configureDarkOverlay];
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH)/2;
        NSInteger yOrigin = (([UIScreen mainScreen].bounds.size.height - 334)/2);
        self.frame = CGRectMake(xOrigin, yOrigin - 20, ALERT_WIDTH, 334);
        
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
        
        UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        locationButton.frame = CGRectMake(0, 136, self.frame.size.width, 44);
        [locationButton setTitle:@"ENABLE LOCATION" forState:UIControlStateNormal];
        [locationButton setTintColor:[UIColor frescoDarkTextColor]];
        [locationButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        
        UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-marker"]];
        [locationButton setImage:locationImageView.image forState:UIControlStateNormal];
        locationButton.imageEdgeInsets = UIEdgeInsetsMake(0, -49, 0, 49);
        locationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [self addSubview:locationButton];
        
        UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        notificationButton.frame = CGRectMake(0, 136+44, self.frame.size.width, 44);
        [notificationButton setTitle:@"ENABLE NOTIFICATIONS" forState:UIControlStateNormal];
        [notificationButton setTintColor:[UIColor frescoDarkTextColor]];
        [notificationButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        
        UIImageView *notificationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bell"]];
        [notificationButton setImage:notificationImageView.image forState:UIControlStateNormal];
        notificationButton.imageEdgeInsets = UIEdgeInsetsMake(0, -32, 0, 32);
        notificationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [self addSubview:notificationButton];
        
        UITextView *locationTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 192+44-10, ALERT_WIDTH, 42)];
        locationTextView.userInteractionEnabled  = NO;
        locationTextView.clipsToBounds = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = -2;
        paragraphStyle.minimumLineHeight = -100;
        
        locationTextView.attributedText = [[NSAttributedString alloc] initWithString:@"Your location is only shared when you \n post a gallery to Fresco. In all other cases \n your location is fully anonymous."
                                                                           attributes:
                                            @{NSParagraphStyleAttributeName : paragraphStyle,
                                              NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightLight]}];
        
        locationTextView.textAlignment = NSTextAlignmentCenter;
        locationTextView.textColor = [UIColor frescoMediumTextColor];
        locationTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:locationTextView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 290, self.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor frescoShadowColor];
        [self addSubview:line];
        
        UIButton *askLaterButton = [UIButton buttonWithType:UIButtonTypeSystem];
        askLaterButton.frame =  CGRectMake(0, 0, 104, 44);
        [askLaterButton.titleLabel setText:@"ASK LATER"];
        [askLaterButton.titleLabel setTextColor:[UIColor darkTextColor]];
        [self addSubview:askLaterButton];
        
        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}




@end
