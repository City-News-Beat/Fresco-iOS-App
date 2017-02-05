//
//  FRSPaymentViewController.h
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "Fresco.h"
#import "FRSPaymentCell.h"

@interface FRSPaymentViewController : FRSBaseViewController <UITableViewDelegate, UITableViewDataSource, FRSPaymentCellDelegate> {
    NSInteger selectedIndex;
    BOOL isSelectingPayment;
}

@property (nonatomic, retain) NSArray *payments;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
