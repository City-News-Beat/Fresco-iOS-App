//
//  NotificationsViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NotificationsViewController.h"
#import "AssignmentNotificationCell.h"

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *data;
@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 96;
    
    NSArray *someData = @[
                          @{@"eventName" : @"St. Patrick's Day Parade",
                            @"eventDescription" : @"The parade has started heading north from 5th Avenue and 44th Street.",
                            @"eventTime" : @"2h"},
                          
                          @{@"eventName" : @"Another dreaded street fair",
                            @"eventDescription" : @"NY is innundated once again by faceless traffic stopping street fairs. Yay summer!",
                            @"eventTime" : @"1h"},
                          
                          @{@"eventName" : @"Losers hanging out at the bar",
                            @"eventDescription" : @"Title says it all.",
                            @"eventTime" : @"3d"},
                          
                          ];
    
    self.data = [NSArray arrayWithArray:someData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // since there is a section for every story
    // and just one story per section
    // the section will tell us the "row"
    // NSUInteger index = indexPath.section;
    
    AssignmentNotificationCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"assignmentCell" forIndexPath:indexPath];
    
    tableViewCell.title.text = @"New Assignment";
    tableViewCell.eventName.text = [[self.data objectAtIndex:indexPath.row] objectForKey:@"eventName"];
    tableViewCell.assignDescription.text = [[self.data objectAtIndex:indexPath.row] objectForKey:@"eventDescription"];
    tableViewCell.timeElapsed.text = [[self.data objectAtIndex:indexPath.row] objectForKey:@"eventTime"];
    
    return tableViewCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     UITableViewCell *tableViewCellHeader = [[UITableViewCell alloc] init];
    
    return tableViewCellHeader;
}


@end
