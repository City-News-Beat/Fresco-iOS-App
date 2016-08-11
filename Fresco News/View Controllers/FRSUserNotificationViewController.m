//
//  FRSUserNotificationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationViewController.h"
#import "FRSDefaultNotificationTableViewCell.h"
#import "FRSTextNotificationTableViewCell.h"

@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSUserNotificationViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    [self configureUI];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSDefaultNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"notificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTextNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"textNotificationCell"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}



#pragma mark - UI

-(void)configureUI {
    [self configureBackButtonAnimated:NO];
    [self configureNavigationBar];
    [self configureTableView];
}

-(void)configureNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    self.title = @"ACTIVITY";
}

-(void)configureTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    
    [self.view addSubview:self.tableView];
}



#pragma mark - UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSString *cellIdentifier = @"notificationCell";
//    FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    cell.titleLabel.text = @"Omar Elfanek";
//    cell.bodyLabel.text  = @"Followed you.";
//    cell.count = 2;
//
//    [cell configureCell];
    
    
    NSString *cellIdentifier = @"textNotificationCell";
    FRSTextNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.bodyLabel.text  = @"BREAKING: Wild elephant runs down FDR chasing a small dog. No injuries reported.";
    
    [cell configureCell];
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}














@end
