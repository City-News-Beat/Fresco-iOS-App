//
//  FRSRadiusViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRadiusViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"


@interface FRSRadiusViewController()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSRadiusViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureTableView];
}


-(void)configureTableView{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.title = @"DISABLE MY ACCOUNT";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.showsVerticalScrollIndicator = NO;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:self.tableView];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            return self.view.frame.size.height/2;
            break;
            
        default:;
            break;
    }
    return 56;
}

-(FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier;
    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            [cell configureMapCell];

            
            break;
        case 1:
            [cell configureSliderCell];
            [cell configureCellWithRightAlignedButtonTitle:@"SAVE RADIUS" withWidth:173];

            
        default:
            break;
    }
}


@end
