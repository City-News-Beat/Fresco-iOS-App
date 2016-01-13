//
//  FRSPasswordChangeViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPasswordChangeViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"

@interface FRSPasswordChangeViewController ()

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSPasswordChangeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
}

-(void)configureTableView{
    self.title = @"PASSWORD";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
            [cell configureEditableCellWithDefaultText:@"Current password" withTopSeperator:YES withBottomSeperator:YES isSecure:YES];
            break;
            
        case 1:
            [cell configureEditableCellWithDefaultText:@"New password" withTopSeperator:NO withBottomSeperator:YES isSecure:YES];
            break;
        
        case 2:
            [cell configureEditableCellWithDefaultText:@"Confirm new password" withTopSeperator:NO withBottomSeperator:YES isSecure:YES];
            [cell configureCellWithRightAlignedButtonTitle:@"SAVE TAX INFO" withWidth:143];
            break;
            
        default:
            break;
    }
    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

@end
