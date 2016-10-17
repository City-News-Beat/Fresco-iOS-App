//
//  FRSPaymentCell.m
//  Fresco
//
//  Created by Philip Bernstein on 8/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPaymentCell.h"

@implementation FRSPaymentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)deletePayment:(id)sender {
    if (_delegate) {
        [_delegate deleteButtonClicked:self.payment];
    }
}

-(void)setActive:(BOOL)active {
    self.isActive = active;
    
    if (active) {
        self.selectionCircle.image = [UIImage imageNamed:@"check-box-circle-filled"];
        self.deletionButton.hidden = TRUE;
    }
    else {
        self.selectionCircle.image = [UIImage imageNamed:@"check-box-circle-outline"];
        self.deletionButton.hidden = FALSE;
    }
}
@end
