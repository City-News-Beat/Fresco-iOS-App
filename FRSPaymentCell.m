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
    NSLog(@"PAY: %@", self.payment);
}

-(void)setActive:(BOOL)active {
    self.isActive = active;
    
    if (active) {
        self.selectionCircle.image = [UIImage imageNamed:@"check-box-circle-filled"];
    }
    else {
        self.selectionCircle.image = [UIImage imageNamed:@"check-box-circle-outline"];
    }
}
@end
