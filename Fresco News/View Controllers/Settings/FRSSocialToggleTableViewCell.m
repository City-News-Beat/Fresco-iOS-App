 
    //
//  FRSSocialToggleTableViewCell.m
//  Fresco
//
//  Created by Maurice Wu on 2/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSocialToggleTableViewCell.h"

@interface FRSSocialToggleTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic) SocialType socialType;

@end

@implementation FRSSocialToggleTableViewCell

- (void)setupImage:(UIImage *)image andSwitchColor:(UIColor *)color type:(SocialType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.iconImageView.image = image;
      self.connectedSwitch.onTintColor = color;
    });
    self.socialType = type;
    switch (type) {
    case TwitterType:
        [self setupTwitterCell];
        break;
    case FacebookType:
        [self setupFacebookCell];
        break;
    default:
        break;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupTwitterCell {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:twitterHandle]) {
        self.socialLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:twitterHandle];
        [self.connectedSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:twitterConnected]];
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:twitterConnected]) {
            self.socialLabel.text = @"Twitter Connected";
            [self.connectedSwitch setOn:YES];
        } else {
            self.socialLabel.text = @"Connect Twitter";
            [self.connectedSwitch setOn:NO];
        }
    }
}

- (void)setupFacebookCell {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:facebookName]) {
        self.socialLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:facebookName];
        [self.connectedSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:facebookConnected]];
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:facebookConnected]) {
            self.socialLabel.text = @"Facebook Connected";
            [self.connectedSwitch setOn:YES];
        } else {
            self.socialLabel.text = @"Connect Facebook";
            [self.connectedSwitch setOn:NO];
        }
    }
}

- (IBAction)toggle:(id)sender {
    switch (self.socialType) {
    case FacebookType:
        [self.delegate didToggleFacebook:self.connectedSwitch withLabel:self.socialLabel];
        break;
    case TwitterType:
        [self.delegate didToggleTwitter:self.connectedSwitch withLabel:self.socialLabel];
        break;
    }
}

@end
        
