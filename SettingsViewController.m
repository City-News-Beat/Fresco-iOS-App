//
//  SettingsViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

@interface SettingsViewController ()

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SettingsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];

}

-(void)configureTableView{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self.view addSubview:self.tableView];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HistoryCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = @"test";
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}


















@end
