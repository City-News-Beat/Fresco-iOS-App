//
//  FRSModerationAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSModerationAlertView.h"
#import "UIFont+Fresco.h"

@interface FRSModerationAlertView () <UITextViewDelegate>

@property (strong, nonatomic) UIImageView *moderationIVOne;
@property (strong, nonatomic) UIImageView *moderationIVTwo;
@property (strong, nonatomic) UIImageView *moderationIVThree;
@property (strong, nonatomic) UIImageView *moderationIVFour;
@property (strong, nonatomic) UILabel *textViewPlaceholderLabel;

@end

@implementation FRSModerationAlertView

- (instancetype)initUserReportWithUsername:(NSString *)username delegate:(id)delegate {
    self = [super init];
    delegate = self.delegate;

    if (self) {

        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 356 / 2, ALERT_WIDTH, 356);

        [self configureDarkOverlay];

        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = [NSString stringWithFormat:@"REPORT %@", [username uppercaseString]];
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"What is this user doing?"];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"What is this user doing?" length])];

        self.messageLabel.attributedText = attributedString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];

        /* Shadows */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];

        UIView *actionLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, ALERT_WIDTH, 0.5)];
        actionLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:actionLine];

        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(actionTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(16, self.frame.size.height - 44, 121, 44);
        self.actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];

        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 101, 44);
        [self.cancelButton addTarget:self action:@selector(reportUser) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"SEND REPORT" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        self.cancelButton.userInteractionEnabled = NO;
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];

        self.moderationIVOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
        self.moderationIVTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
        self.moderationIVThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];

        [self createSelectableButtonWithTitle:@"Being abusive" imageView:self.moderationIVOne yPos:76 action:@selector(didTapOptionOne)];
        [self createSelectableButtonWithTitle:@"Posting spam" imageView:self.moderationIVTwo yPos:120 action:@selector(didTapOptionTwo)];
        [self createSelectableButtonWithTitle:@"Posting stolen content" imageView:self.moderationIVThree yPos:164 action:@selector(didTapOptionThree)];

        [self addTextView];

        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

- (instancetype)initGalleryReportDelegate:(id)delegate {
    self = [super init];

    if (self) {
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 356 / 2, ALERT_WIDTH, 400);

        [self configureDarkOverlay];

        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"REPORT GALLERY";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"What’s wrong with this gallery?"];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"What’s wrong with this gallery?" length])];

        self.messageLabel.attributedText = attributedString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];

        /* Shadows */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];

        UIView *actionLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, ALERT_WIDTH, 0.5)];
        actionLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:actionLine];

        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(actionTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(16, self.frame.size.height - 44, 121, 44);
        self.actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];

        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 101, 44);
        [self.cancelButton addTarget:self action:@selector(reportGallery) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"SEND REPORT" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        self.cancelButton.userInteractionEnabled = NO;
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];

        self.moderationIVOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
        self.moderationIVTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
        self.moderationIVThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
        self.moderationIVFour = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];

        [self createSelectableButtonWithTitle:@"It’s abusive" imageView:self.moderationIVOne yPos:76 action:@selector(didTapOptionOne)];
        [self createSelectableButtonWithTitle:@"It’s spam" imageView:self.moderationIVTwo yPos:120 action:@selector(didTapOptionTwo)];
        [self createSelectableButtonWithTitle:@"It includes stolen content" imageView:self.moderationIVThree yPos:164 action:@selector(didTapOptionThree)];
        [self createSelectableButtonWithTitle:@"It includes graphic content" imageView:self.moderationIVFour yPos:208 action:@selector(didTapOptionFour)];

        [self addTextView];

        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

- (void)createSelectableButtonWithTitle:(NSString *)title imageView:(UIImageView *)imageView yPos:(CGFloat)yPos action:(SEL)action {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, yPos, self.frame.size.width, 44);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 200, 20)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    titleLabel.textColor = [UIColor frescoDarkTextColor];
    [button addSubview:titleLabel];

    imageView.frame = CGRectMake(self.frame.size.width - 26 - 16, 10, 24, 24);
    [button addSubview:imageView];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, ALERT_WIDTH, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [button addSubview:line];
}

- (void)addTextView {

    int textViewHeight = 93;
    int padding = 44;

    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(16, self.frame.size.height - textViewHeight - padding, self.frame.size.width - 32, textViewHeight)];
    self.textView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.tintColor = [UIColor frescoBlueColor];
    [self addSubview:self.textView];

    self.textViewPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 6, self.frame.size.width - 32, 17)];
    self.textViewPlaceholderLabel.text = @"Please share more details";
    self.textViewPlaceholderLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textViewPlaceholderLabel.textColor = [UIColor frescoLightTextColor];
    [self.textView addSubview:self.textViewPlaceholderLabel];

    self.dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.dismissKeyboardTap];
}

- (void)tap {
    [self resignFirstResponder];
    [self endEditing:YES];
}

- (void)didTapOptionOne {
    [self toggleImageView:self.moderationIVOne];
    [self.delegate didPressRadioButtonAtIndex:0];
}

- (void)didTapOptionTwo {
    [self toggleImageView:self.moderationIVTwo];
    [self.delegate didPressRadioButtonAtIndex:1];
}

- (void)didTapOptionThree {
    [self toggleImageView:self.moderationIVThree];
    [self.delegate didPressRadioButtonAtIndex:2];
}

- (void)didTapOptionFour {
    [self toggleImageView:self.moderationIVFour];
    [self.delegate didPressRadioButtonAtIndex:3];
}

- (void)toggleImageView:(UIImageView *)imageView {
    [self untoggleRadioButtons];

    if ([imageView.image isEqual:[UIImage imageNamed:@"check-box-circle-outline"]]) {
        imageView.image = [UIImage imageNamed:@"check-box-circle-filled"];
    } else {
        imageView.image = [UIImage imageNamed:@"check-box-circle-outline"];
    }

    if ([self.moderationIVOne.image isEqual:[UIImage imageNamed:@"check-box-circle-filled"]] || [self.moderationIVTwo.image isEqual:[UIImage imageNamed:@"check-box-circle-filled"]] || [self.moderationIVThree.image isEqual:[UIImage imageNamed:@"check-box-circle-filled"]] || [self.moderationIVFour.image isEqual:[UIImage imageNamed:@"check-box-circle-filled"]]) {
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.cancelButton.userInteractionEnabled = YES;
    } else {
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cancelButton.userInteractionEnabled = NO;
    }
}

- (void)untoggleRadioButtons {
    self.moderationIVOne.image = [UIImage imageNamed:@"check-box-circle-outline"];
    self.moderationIVTwo.image = [UIImage imageNamed:@"check-box-circle-outline"];
    self.moderationIVThree.image = [UIImage imageNamed:@"check-box-circle-outline"];
    self.moderationIVFour.image = [UIImage imageNamed:@"check-box-circle-outline"];
}

- (void)reportGallery {
    [self dismiss];
    [self.delegate reportGalleryAlertAction];
}

- (void)reportUser {
    [self dismiss];
    [self.delegate reportUserAlertAction];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.textViewPlaceholderLabel.alpha = 0;
                       if (IS_IPHONE_6) {
                           self.transform = CGAffineTransformMakeTranslation(0, -150);
                       } else if (IS_IPHONE_5) {
                           self.transform = CGAffineTransformMakeTranslation(0, -200);
                       } else if (IS_IPHONE_6_PLUS) {
                           self.transform = CGAffineTransformMakeTranslation(0, -100);
                       }
                     }
                     completion:nil];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       if ([textView.text isEqualToString:@""]) {
                           self.textViewPlaceholderLabel.alpha = 1;
                       }
                       self.transform = CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:nil];
}

@end
