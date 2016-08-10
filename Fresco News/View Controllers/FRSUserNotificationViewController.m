//
//  FRSUserNotificationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationViewController.h"
#import "FRSDefaultNotificationTableViewCell.h"

@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSUserNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureUI];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}



#pragma mark - UI

-(void)configureUI {
    [self configureBackButtonAnimated:NO];
    [self configureTableView];
}

-(void)configureTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.tableView];
}



#pragma mark - UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[FRSDefaultNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSDefaultNotificationTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    cell.titleLabel.text = @"Today in News";
    cell.bodyLabel.text  = @"My money's in that office, right? If she start giving me some bullshit about it ain't there, and we got to go…";
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
















@end
