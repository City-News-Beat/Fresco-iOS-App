//
//  FRSPaymentCell.h
//  Fresco
//
//  Created by Philip Bernstein on 8/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSPaymentCellDelegate
- (void)deleteButtonClicked:(NSDictionary *)payment;
@end

@interface FRSPaymentCell : UITableViewCell {
}

@property (nonatomic, copy) void (^deletionBlock)(NSDictionary *payment);

@property (nonatomic, weak) IBOutlet UILabel *paymentTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *selectionCircle;
@property (nonatomic, weak) IBOutlet UIButton *deletionButton;

@property (nonatomic, retain) NSDictionary *payment;
@property (nonatomic, weak) id<FRSPaymentCellDelegate> delegate;

@property BOOL isActive;

- (IBAction)deletePayment:(id)sender;
- (void)setActive:(BOOL)active;
- (void)startSpinner;
- (void)stopSpinner;

@end
