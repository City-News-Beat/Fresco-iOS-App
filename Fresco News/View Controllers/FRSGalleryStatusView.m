//
//  FRSGalleryStatusView.m
//  Fresco
//
//  Created by Arthur De Araujo on 1/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryStatusView.h"

@implementation FRSGalleryStatusView{
    
    IBOutlet UIView *popupView;
    IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
    
    // Submitted
    IBOutlet UIImageView *submittedCheckImageView;
    IBOutlet UILabel *submittedLabel;
    
    // Verified
    IBOutlet UIView *verifiedLineView;
    IBOutlet NSLayoutConstraint *verifiedLineHeightConstraint;
    
    IBOutlet UIImageView *verifiedCheckImageView;
    IBOutlet UILabel *verifiedTitleLabel;
    IBOutlet UILabel *verifiedDescriptionLabel;
    
    // Sold
    IBOutlet UIView *soldLineView;
    IBOutlet UILabel *soldLabel;
    IBOutlet UITableView *soldContentTableView;
    IBOutlet UIImageView *soldCashIconImageView;
}

-(void)configureWithArray:(NSArray *)purchases rating:(int)rating{
    [self addLayerShadowAndRadius];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self animateIn];
    
    if (rating == 0){// Not Rated | PENDING VERIFICATION
        [self setToPendingVerification];
    }else if(rating == 1){// Skipped | NOT VERIFIED
        
    }else if(rating == 2 || rating == 3){// Verified or Highlighted | VERIFIED

    }else if(rating == 4){// DELETED

    }
}

-(void)setToPendingVerification{
    popupViewHeightConstraint.constant = 230;
    
    soldLabel.hidden = true;
    soldLineView.hidden = true;
    soldContentTableView.hidden = true;
    soldCashIconImageView.hidden = true;

    verifiedTitleLabel.text = @"Pending Verification";
    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    
    verifiedDescriptionLabel.text = @"Once we’ve verified your gallery, news outlets will be able to purchase content.";
    
    verifiedLineView.backgroundColor = [UIColor frescoOrangeColor];
    verifiedLineHeightConstraint.constant = 36;
    
    [verifiedCheckImageView setImage:[UIImage imageNamed:@"checkboxBlankCircleOutline24Y"]];
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
//                         self.titleLabel.alpha = 1;
//                         self.cancelButton.alpha = 1;
//                         self.actionButton.alpha = 1;
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.26];
                         self.transform = CGAffineTransformMakeScale(1, 1);
                         
                     } completion:nil];
}

-(void)animateOut {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 0;
//                         self.titleLabel.alpha = 0;
//                         self.cancelButton.alpha = 0;
//                         self.actionButton.alpha = 0;
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                         self.transform = CGAffineTransformMakeScale(0.9, 0.9);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

-(void)addLayerShadowAndRadius{
    popupView.layer.shadowColor = [UIColor blackColor].CGColor;
    popupView.layer.shadowOffset = CGSizeMake(0, 4);
    popupView.layer.shadowRadius = 2;
    popupView.layer.shadowOpacity = 0.1;
    popupView.layer.cornerRadius = 2;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
