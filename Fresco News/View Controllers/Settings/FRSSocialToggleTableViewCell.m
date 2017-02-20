//
//  FRSSocialToggleTableViewCell.m
//  Fresco
//
//  Created by Maurice Wu on 2/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSocialToggleTableViewCell.h"

@interface FRSSocialToggleTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *socialLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UISwitch *connectedSwitch;

@end

@implementation FRSSocialToggleTableViewCell

- (void)setupText:(NSString *)text withImage:(UIImage *)image andSwitchColor:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.socialLabel.text = text;
        self.iconImageView.image = image;
        self.connectedSwitch.tintColor = color;
    });
}

- (void)loadText:(NSString *)text connected:(BOOL)connected {
    
}



//- (void)didPressButtonAtIndex:(NSInteger)index {
//    if (self.didToggleTwitter) {
//        self.didToggleTwitter = NO;
//        if (index == 0) {
//            [self.twitterSwitch setOn:YES animated:YES];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"twitter-connected"];
//        } else {
//            [self.twitterSwitch setOn:NO animated:YES];
//            self.twitterHandle = nil;
//            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"twitter-handle"];
//            self.socialTitleLabel.text = @"Connect Twitter";
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];
//        }
//    } else if (self.didToggleFacebook) {
//        self.didToggleFacebook = NO;
//        if (index == 0) {
//            [self.facebookSwitch setOn:YES animated:YES];
//        } else if (index == 1) {
//            [self.facebookSwitch setOn:NO animated:YES];
//            self.facebookName = nil;
//            self.socialTitleLabel.text = @"Connect Facebook";
//        }
//    }
//    
//    self.alert = nil;
//}

@end
