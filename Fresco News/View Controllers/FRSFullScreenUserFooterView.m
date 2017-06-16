//
//  FRSFullScreenUserFooterView.m
//  
//
//  Created by Omar Elfanek on 6/15/17.
//

#import "FRSFullScreenUserFooterView.h"
#import "FRSUserManager.h"
#import "NSURL+Fresco.h"
#import "Haneke.h"

#define HEIGHT 72

@interface FRSFullScreenUserFooterView ()

@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) FRSUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userFullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@end

@implementation FRSFullScreenUserFooterView

- (instancetype)initWithUser:(FRSUser *)user delegate:(id)delegate {
    self = [super init];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - HEIGHT, [UIScreen mainScreen].bounds.size.width, HEIGHT);
        self.backgroundColor = [UIColor redColor];
        self.user = user;
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI {
    [self configureGradient];
    [self configureUserImageView];
    [self configureLabels];
}

- (void)configureGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    UIColor *startColor = [UIColor colorWithWhite:0 alpha:0];
    UIColor *endColor = [UIColor colorWithWhite:0 alpha:0.42];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
}

- (void)configureUserImageView {
    
    NSURL *avatarURL;
    if (![self.user.profileImage isEqual:[NSNull null]]) {
        avatarURL = [NSURL URLResizedFromURLString:self.user.profileImage width:self.userImageView.frame.size.width * 3]; // Multiplying by 3 to render 3x on iPhone 6/7+ devices
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.userImageView hnk_setImageFromURL:avatarURL placeholder:[UIImage imageNamed:@"user-24"]];
        if (avatarURL) {
            [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
            self.backgroundColor = [UIColor frescoRedColor];
        } else {
            [self.userImageView setContentMode:UIViewContentModeCenter];
        }
        
        if (self.user.uid && [[FRSUserManager sharedInstance] authenticatedUser].uid && [self.user.uid isEqualToString:[[FRSUserManager sharedInstance] authenticatedUser].uid]) {
            self.followButton.hidden = YES;
        } else {
            self.followButton.hidden = NO;
        }
    });
    
    [self.userImageView setImage:self.user.profileImage];
}

- (void)configureLabels {
    self.userFullNameLabel.text = self.user.firstName;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
}

@end
