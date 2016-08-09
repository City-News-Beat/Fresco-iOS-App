//
//  FRSUserNotificationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationViewController.h"

@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FRSUserNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureBackButtonAnimated:NO];

    


}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}

-(void)configureTableView {
    

    
    
    
}















@end
