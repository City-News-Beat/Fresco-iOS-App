//
//  FRSTaxInformationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTaxInformationViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"


@interface FRSTaxInformationViewController()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end


@implementation FRSTaxInformationViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
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
            return 3;
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
                    [cell configureDefaultCellWithTitle:@"Business type" andCarret:YES andRightAlignedTitle:@"Individual"];
//                    [cell configureEditableCellWithDefaultText:@"Address"];

                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Name" withTopSeperator:YES withBottomSeperator:YES];
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultText:@"Tax ID # (SSN or EIN)" withTopSeperator:NO withBottomSeperator:YES];
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
                    [cell configureEditableCellWithDefaultText:@"Address" withTopSeperator:YES withBottomSeperator:YES];
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Unit # (optional)" withTopSeperator:NO withBottomSeperator:YES];
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultText:@"City" withTopSeperator:NO withBottomSeperator:YES];
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE PASSWORD" withWidth:143];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    //First cell needs a selection style, see FRSSettingsTableView
    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    
}

@end
