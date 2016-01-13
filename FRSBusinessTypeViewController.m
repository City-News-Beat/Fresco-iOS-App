//
//  FRSBusinessTypeViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBusinessTypeViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"

@interface FRSBusinessTypeViewController() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSBusinessTypeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
}

-(void)configureTableView{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    
    self.title = @"";
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
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
            [cell configureCheckBoxCellWithTitle:@"Individual/Sole Proprietorship" withTopSeperator:YES withBottomSeperator:NO isSelected:YES];
            break;
        case 1:
            [cell configureCheckBoxCellWithTitle:@"Partnership" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
        case 2:
            [cell configureCheckBoxCellWithTitle:@"LLC (Partnership class)" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
        case 3:
            [cell configureCheckBoxCellWithTitle:@"LLC (C class)" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
        case 4:
            [cell configureCheckBoxCellWithTitle:@"LLC (S class)" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
        case 5:
            [cell configureCheckBoxCellWithTitle:@"C corporation" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
        case 6:
            [cell configureCheckBoxCellWithTitle:@"S corporation" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
        case 7:
            [cell configureCheckBoxCellWithTitle:@"Trust" withTopSeperator:NO withBottomSeperator:NO isSelected:NO];
            break;
            
        default:
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0:

            break;
        case 1:

            break;
        case 2:

            break;
        case 3:

            break;
        case 4:

            break;
        case 5:

            break;
        case 6:

            break;
        case 7:

            break;
            
        default:
            break;
    }
    
    
}
























@end
