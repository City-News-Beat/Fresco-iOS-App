//
//  FRSPaymentViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPaymentViewController.h"

@interface FRSPaymentViewController ()

@end

@implementation FRSPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.navigationItem setTitle:@"PAYMENT METHOD"];

    [self reloadPayments];
}

-(void)reloadPayments {
    [[FRSAPIClient sharedClient] fetchPayments:^(id responseObject, NSError *error) {
        if (error || !responseObject) {
            [self fetchError:error];
            return;
        }
        
        self.payments = responseObject;
    }];
}

-(void)fetchError:(NSError *)error {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
