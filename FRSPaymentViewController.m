//
//  FRSPaymentViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPaymentViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSPaymentCell.h"
#import "FRSAddPaymentCell.h"
#import "FRSAppDelegate.h"
#import "FRSUserManager.h"

@interface FRSPaymentViewController ()
@end

@implementation FRSPaymentViewController

static NSString *paymentCell = @"paymentCell";
static NSString *addPaymentCell = @"addPaymentCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setTitle:@"PAYMENT METHOD"];

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSPaymentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:paymentCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAddPaymentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:addPaymentCell];

    [self configureBackButtonAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self reloadPayments];
    [FRSTracker screen:@"Payment Method"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.payments.count;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FRSPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:paymentCell];
        __block NSDictionary *payment = self.payments[indexPath.row];
        cell.paymentTitleLabel.text = [NSString stringWithFormat:@"%@ (%@)", payment[@"brand"], payment[@"last4"]];
        cell.payment = self.payments[indexPath.row];
        if ([payment[@"active"] boolValue]) {
            [cell setActive:YES];
        } else {
            [cell setActive:NO];
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    } else if (indexPath.section == 1) {
        FRSAddPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:addPaymentCell];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }

    return Nil;
}

- (void)deletePayment:(NSIndexPath *)path {
    NSDictionary *pay = self.payments[path.row];

    [[FRSAPIClient sharedClient] deletePayment:pay[@"id"]
                                    completion:^(id responseObject, NSError *error) {
                                      [self reloadPayments];
                                    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        FRSDebitCardViewController *debit = [[FRSDebitCardViewController alloc] init];
        [self.navigationController pushViewController:debit animated:YES];
    } else {
        if (indexPath.row == selectedIndex) {
            return;
        }

        NSDictionary *payment = [self.payments objectAtIndex:indexPath.row];
        NSString *paymentID = payment[@"id"];
        NSString *digits = [NSString stringWithFormat:@"%@ (%@)", payment[@"brand"], payment[@"last4"]];
        [[[FRSUserManager sharedInstance] authenticatedUser] setValue:digits forKey:@"creditCardDigits"];
        [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];

        [[NSUserDefaults standardUserDefaults] setObject:digits forKey:settingsPaymentLastFour];

        [[FRSAPIClient sharedClient] makePaymentActive:paymentID
                                            completion:^(id responseObject, NSError *error) {
                                              if (!error) {
                                                  [self resetOtherPayments:paymentID];
                                              }
                                            }];
    }
}

- (void)resetOtherPayments:(NSString *)activePayment {
    NSInteger i = 0;
    for (FRSPaymentCell *cell in self.tableView.visibleCells) {
        if (i >= self.payments.count) {
            return;
        }

        NSDictionary *payment = self.payments[i];
        if ([payment[@"id"] isEqualToString:activePayment]) {
            [cell setActive:YES];
        } else {
            [cell setActive:NO];
        }

        i++;
    }
}

- (void)reloadPayments {
    [[FRSAPIClient sharedClient] fetchPayments:^(id responseObject, NSError *error) {
      if (error || !responseObject) {
          return;
      }

      self.payments = responseObject;

      if (self.payments.count > 1) {
          [self.navigationItem setTitle:@"PAYMENT METHODS"];
      } else {
          [self.navigationItem setTitle:@"PAYMENT METHOD"];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
      });
    }];
}

- (void)deleteButtonClicked:(NSDictionary *)payment {

    if (!payment) {
        return;
    }

    [[FRSAPIClient sharedClient] deletePayment:payment[@"id"]
                                    completion:^(id responseObject, NSError *error) {
                                      NSLog(@"%@", responseObject);
                                      if (!error) {
                                          [self reloadPayments];
                                      }
                                    }];
}

@end
