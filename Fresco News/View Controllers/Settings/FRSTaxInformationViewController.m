//
//  FRSTaxInformationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTaxInformationViewController.h"
#import "FRSBusinessTypeViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"


@interface FRSTaxInformationViewController()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *businessType;

@end


@implementation FRSTaxInformationViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"selected-business-type" object:nil];
    
    
    NSInteger tag = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected-tag"];
    NSLog(@"tag = %ld", (long)tag);
    
    
    switch (tag) {
        case 1:
            self.businessType = @"Individual";
            break;
            
        case 2:
            self.businessType = @"Partnership";
            break;
            
        case 3:
            self.businessType = @"LLC (Partnership class)";
            break;
            
        case 4:
            self.businessType = @"LLC (C class)";
            break;
            
        case 5:
            self.businessType = @"LLC (S class)";
            break;
            
        case 6:
            self.businessType = @"C corporation";
            break;
            
        case 7:
            self.businessType = @"S corporation";
            break;
            
        case 8:
            self.businessType = @"Trust";
            break;
            
        default:
            break;
    }
    
    
    [self configureTableView];
}



- (void) incomingNotification:(NSNotification *)notification{
    self.businessType = [notification object];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

-(void)configureTableView{
    self.title = @"TAX INFORMATION";
    
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
                    
                    NSLog(@"self.businessType = %@", self.businessType);
                    if ([self.businessType  isEqual: @"Individual/Sole Proprietorship"]) {
                        [cell configureDefaultCellWithTitle:@"Business type" andCarret:YES andRightAlignedTitle:@"Individual"];
                    } else {
                        [cell configureDefaultCellWithTitle:@"Business type" andCarret:YES andRightAlignedTitle:self.businessType];
                    }

                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultText:@"Tax ID # (SSN or EIN)" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeNumberPad];
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
                    [cell configureEditableCellWithDefaultText:@"City" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                
                case 3:
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE TAX INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
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

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    FRSBusinessTypeViewController *businessType = [[FRSBusinessTypeViewController alloc] init];
                    [self.navigationController pushViewController:businessType animated:YES];
                    self.navigationItem.title = @"";
                }
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
}

@end
