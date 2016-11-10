//
//  FRSCommentCell.h
//  Fresco
//
//  Created by Philip Bernstein on 8/24/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "FRSComment.h"

@protocol FRSCommentCellDelegate <NSObject>

-(void)didPressProfilePictureWithUserId:(NSString *)uid;

@end

@interface FRSCommentCell : MGSwipeTableCell
@property (nonatomic, retain) IBOutlet UIImageView *profilePicture;
@property (nonatomic, retain) IBOutlet UITextView *commentTextView;

@property (weak, nonatomic) NSObject<FRSCommentCellDelegate> *cellDelegate;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) FRSComment *comment;

- (void)configureCell:(FRSComment *)comment delegate:(id<UITextViewDelegate>)delegate;
@end
