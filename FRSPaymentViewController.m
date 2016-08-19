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

@interface FRSPaymentViewController ()
@end

@implementation FRSPaymentViewController

static NSString *paymentCell = @"paymentCell";
static NSString *addPaymentCell = @"addPaymentCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.navigationItem setTitle:@"PAYMENT METHOD"];

    [self setupTableView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadPayments];
}

-(void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -35, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSPaymentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:paymentCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAddPaymentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:addPaymentCell];
    [self.view addSubview:self.tableView];
    self.tableView.showsVerticalScrollIndicator = FALSE;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.payments.count;
    }
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FRSPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:paymentCell];
        __block NSDictionary *payment = self.payments[indexPath.row];
        cell.paymentTitleLabel.text = [NSString stringWithFormat:@"%@ (%@)", payment[@"brand"], payment[@"last4"]];
        cell.payment = self.payments[indexPath.row];
        
        if ([payment[@"active"] boolValue]) {
            [cell setActive:TRUE];
        }
        else {
            [cell setActive:FALSE];
        }
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:addPaymentCell];
        return cell;
    }
    
    return Nil;
}

-(void)deletePayment:(NSIndexPath *)path {
    NSDictionary *pay = self.payments[path.row];
    NSLog(@"%@", pay);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        FRSDebitCardViewController *debit = [[FRSDebitCardViewController alloc] init];
        [self.navigationController pushViewController:debit animated:YES];
    }
    else {
        if (indexPath.row == selectedIndex) {
            return;
        }
        
        NSDictionary *payment = [self.payments objectAtIndex:indexPath.row];
        NSString *paymentID = payment[@"id"];
        
        [[FRSAPIClient sharedClient] makePaymentActive:paymentID completion:^(id responseObject, NSError *error) {
            if (!error) {
                [self resetOtherPayments:paymentID];
            }
        }];
    }
}

-(void)resetOtherPayments:(NSString *)activePayment {
    
    NSInteger i = 0;
    for (FRSPaymentCell *cell in self.tableView.visibleCells) {
        
        if (i >= self.payments.count) {
            return;
        }
        
        NSDictionary *payment = self.payments[i];
        
        if ([payment[@"id"] isEqualToString:activePayment]) {
            [cell setActive:TRUE];
        }
        else {
            [cell setActive:FALSE];
        }
        
        i++;
    }
}

-(void)reloadPayments {
    [[FRSAPIClient sharedClient] fetchPayments:^(id responseObject, NSError *error) {
        if (error || !responseObject) {
            [self fetchError:error];
            return;
        }
        
        NSLog(@"PAYMENTS %@", responseObject);
        self.payments = responseObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

-(void)fetchError:(NSError *)error {
    NSLog(@"PAYMENT ERROR: %@", error);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)deleteButtonClicked:(NSDictionary *)payment {
    
    if (!payment) {
        return;
    }
    
    [[FRSAPIClient sharedClient] deletePayment:payment[@"id"] completion:^(id responseObject, NSError *error) {
        if (!error) {
            [self reloadPayments];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
 brand last4
}
*/

@end
