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
#import "FRSAPIClient.h"

@interface FRSPaymentViewController : FRSBaseViewController<UITableViewDelegate, UITableViewDataSource>
{
    
}
@property (nonatomic, retain) NSArray *payments;
@property (nonatomic, retain) UITableView *tableView;
@end
