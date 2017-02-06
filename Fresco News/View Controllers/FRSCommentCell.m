//
//  FRSCommentCell.m
//  Fresco
//
//  Created by Philip Bernstein on 8/24/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSCommentCell.h"
#import "UIColor+Fresco.h"
#import "Haneke.h"
#import "UITextView+Resize.h"
#import "FRSAuthManager.h"
#import "FRSDateFormatter.h"

@implementation FRSCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profilePicture.layer.cornerRadius = 15;
    self.profilePicture.layer.masksToBounds = YES;
    self.commentTextView.textColor = [UIColor frescoDarkTextColor];
}

- (void)configureCell:(FRSComment *)comment delegate:(id<UITextViewDelegate>)delegate {
    self.comment = comment;

    dispatch_async(dispatch_get_main_queue(), ^{
      if (comment.imageURL && ![comment.imageURL isEqual:[NSNull null]] && ![comment.imageURL isEqualToString:@""]) {

          self.profilePicture.backgroundColor = [UIColor frescoShadowColor];
          NSString *smallAvatar = [comment.imageURL stringByReplacingOccurrencesOfString:@"/images" withString:@"/images/200"];
          [self.profilePicture hnk_setImageFromURL:[NSURL URLWithString:smallAvatar]];
      } else {
          // default
          self.profilePicture.backgroundColor = [UIColor frescoShadowColor];

          UIImageView *userIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-24"]];
          userIcon.frame = CGRectMake(4, 4, 24, 24);
          [self.profilePicture addSubview:userIcon];
      }
    });

    self.commentTextView.attributedText = comment.attributedString;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.commentTextView sizeToFit];
    self.commentTextView.delegate = delegate;

    BOOL userHasName = NO;
    BOOL userHasUsername = NO;

    NSDate *date = [comment updatedAt];
    self.timestampLabel.text = [FRSDateFormatter relativeTimeFromDate:date];

    if (![[comment userDictionary][@"full_name"] isEqual:[NSNull null]] && ![[comment userDictionary][@"full_name"] isEqualToString:@""]) {
        userHasName = YES;
    }

    if (![[comment userDictionary][@"username"] isEqual:[NSNull null]] && ![[comment userDictionary][@"username"] isEqualToString:@""]) {
        userHasUsername = YES;
    }

    if (userHasName && userHasUsername) {
        self.nameLabel.text = [comment userDictionary][@"full_name"];
        self.timestampLabel.text = [NSString stringWithFormat:@"@%@ • %@", [comment userDictionary][@"username"], [FRSDateFormatter relativeTimeFromDate:date]];
    } else if (!userHasName && userHasUsername) {
        self.nameLabel.text = [NSString stringWithFormat:@"@%@", [comment userDictionary][@"username"]];
        self.timestampLabel.text = [FRSDateFormatter relativeTimeFromDate:date];
    } else if (userHasName && !userHasUsername) {
        self.nameLabel.text = [NSString stringWithFormat:@"@%@", [comment userDictionary][@"first_name"]];
        self.timestampLabel.text = [FRSDateFormatter relativeTimeFromDate:date];
    } else if (!userHasUsername && !userHasUsername) {
        self.timestampLabel.transform = CGAffineTransformMakeTranslation(-8, 0);
    }

    if ([self.commentTextView.text containsString:@"@"] || [self.commentTextView.text containsString:@"#"]) {
        self.commentTextView.userInteractionEnabled = YES;
    } else {
        self.commentTextView.userInteractionEnabled = NO;
    }

    if (comment.isDeletable && !comment.isReportable) {
        self.rightButtons = @[ [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"garbage-light"] backgroundColor:[UIColor frescoRedColor]] ];
    } else if (comment.isReportable && !comment.isDeletable) {
        if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
            self.rightButtons = @[ [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"flag-light"] backgroundColor:[UIColor frescoBlueColor]] ];
        }
    } else if (comment.isDeletable && comment.isReportable) {
        self.rightButtons = @[ [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"flag-light"] backgroundColor:[UIColor frescoBlueColor]], [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"garbage-light"] backgroundColor:[UIColor frescoRedColor]] ];
    }

    self.rightSwipeSettings.transition = MGSwipeTransitionDrag;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped)];
    tap.cancelsTouchesInView = NO;
    [self.profilePicture setUserInteractionEnabled:YES];
    [self.profilePicture addGestureRecognizer:tap];
}

- (void)profileTapped {
    if (self.cellDelegate) {
        NSString *userId = self.comment.userDictionary[@"id"];
        [self.cellDelegate didPressProfilePictureWithUserId:userId];
    }
}

@end
