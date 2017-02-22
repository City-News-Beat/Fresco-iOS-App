//
//  FRSSocialToggleTableViewCell.h
//  Fresco
//
//  Created by Maurice Wu on 2/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const socialToggleCellIdentifier = @"social-toggle-cell";
static CGFloat const socialToggleCellHeight = 44;

@protocol FRSSocialToggleTableViewCellDelegate <NSObject>

- (void)didToggleTwitter:(id)sender withLabel:(UILabel *)label;
- (void)didToggleFacebook:(id)sender withLabel:(UILabel *)label;

@end

typedef NS_ENUM(NSInteger, SocialType) {
    TwitterType,
    FacebookType
};

@interface FRSSocialToggleTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *socialLabel;
@property (nonatomic, weak) IBOutlet UISwitch *connectedSwitch;

@property (weak, nonatomic) id<FRSSocialToggleTableViewCellDelegate> delegate;

- (void)setupImage:(UIImage *)image andSwitchColor:(UIColor *)color type:(SocialType)type;

@end
