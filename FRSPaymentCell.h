//
//  FRSPaymentCell.h
//  Fresco
//
//  Created by Philip Bernstein on 8/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSPaymentCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *paymentTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *selectionCircle;
@property (nonatomic, retain) IBOutlet UIButton *deletionButton;
@property (nonatomic, copy) void (^deletionBlock)(NSDictionary *payment);
@property (nonatomic, retain) NSDictionary *payment;

-(IBAction)deletePayment:(id)sender;
@end
