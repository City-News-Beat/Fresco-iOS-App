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

@implementation FRSCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profilePicture.layer.cornerRadius = 15;
    self.profilePicture.layer.masksToBounds = YES;
    self.commentTextView.textColor = [UIColor frescoDarkTextColor];
}

-(void)configureCell:(FRSComment *)comment delegate:(id<UITextViewDelegate>)delegate {
    self.comment = comment;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (comment.imageURL && ![comment.imageURL isEqual:[NSNull null]] && ![comment.imageURL isEqualToString:@""]) {
            NSLog(@"%@", comment.imageURL);
            
            self.backgroundColor = [UIColor clearColor];
            NSString *smallAvatar = [comment.imageURL stringByReplacingOccurrencesOfString: @"/images" withString:@"/images/200"];
            [self.profilePicture hnk_setImageFromURL:[NSURL URLWithString:smallAvatar]];
        }
        else {
            // default
            self.backgroundColor = [UIColor frescoLightTextColor];
            self.profilePicture.image = [UIImage imageNamed:@"user-24"];
        }
    });
    
    self.commentTextView.attributedText = comment.attributedString;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    [self.commentTextView frs_resize];
    self.commentTextView.delegate = delegate;
//    self.commentTextView.backgroundColor = [UIColor redColor];
    
    //Not sure why we need to delay this.
    //Calling size to fit here scales the textview down so the user can
    //tap on the comment cell and begin commenting with the original commenters username pre-loaded.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.commentTextView sizeToFit];
    });
    
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self setPreservesSuperviewLayoutMargins:NO];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
        
    if (comment.isDeletable && !comment.isReportable) {
        self.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"garbage-light"] backgroundColor:[UIColor frescoRedHeartColor]]];
    }else if (comment.isReportable && !comment.isDeletable) {
        if ([[FRSAPIClient sharedClient] isAuthenticated]) {
            self.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"flag-light"] backgroundColor:[UIColor frescoBlueColor]]];
        }
    } else if (comment.isDeletable && comment.isReportable) {
        self.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"flag-light"] backgroundColor:[UIColor frescoBlueColor]], [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"garbage-light"] backgroundColor:[UIColor frescoRedHeartColor]]];
    }
    
    self.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped)];
    tap.cancelsTouchesInView = NO;
    [self.profilePicture setUserInteractionEnabled:YES];
    [self.profilePicture addGestureRecognizer:tap];
    
}

-(void)profileTapped {
    if (self.cellDelegate) {
        NSString *userId = self.comment.userDictionary[@"id"];
        [self.cellDelegate didPressProfilePictureWithUserId:userId];
    }
}

@end
