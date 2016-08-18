//
//  FRSIdentityViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSIdentityViewController.h"
#import "UIColor+Fresco.h"
#import "Fresco.h"
#import "FRSTableViewCell.h"

@interface FRSIdentityViewController()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end


@implementation FRSIdentityViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}


-(void)viewWillAppear:(BOOL)animated{    [self.navigationItem setTitle:@"IDENTIFICATION"];
    [self.tableView reloadData];
}

-(void)configureTableView{
    
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
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return 4;
            break;
        default:
            break;
    }
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 1:
            return 12;
            break;
            
        default:
            return 44;
            break;
    }
    
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
    
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                    
                case 0:
                    //Make custom editible cell
                    [cell configureEditableCellWithDefaultText:@"First name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;

                    
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Last name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultText:@"Date of birth" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeNumberPad];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 1:
            
            [cell configureEmptyCellSpace:NO];
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell configureEditableCellWithDefaultText:@"Address" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Unit # (optional)" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultTextWithMultipleFields:@[@"City", @"State", @"ZIP"] withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                    
                case 3:
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
                    break;
                    
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

}

@end
