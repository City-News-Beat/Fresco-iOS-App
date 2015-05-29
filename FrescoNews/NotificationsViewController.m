//
//  NotificationsViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationCell.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "MTLModel+Additions.h"
#import "FRSNotification.h"
#import "AssignmentsViewController.h"

static NSString *NotificationCellIdentifier = @"NotificationCell";

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *notifications;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAssignmentDescription;

@end

@implementation NotificationsViewController

- (id)init{
    
    if (self = [super init]) {
        _notifications = [[NSMutableArray alloc] init];
    }

    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 119;
    
    _notifications = [[NSMutableArray alloc] init];
    
    [self setFrescoNavigationBar];
    
    /** TEMPORARY */
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm a"];
    
    NSArray *someData = @[
                          @{@"title" : @"New Assignment",
                            @"event" : @"St. Patrick's Day Parade",
                            @"notificationDescription" : @"The parade has started heading north from 5th Avenue and 44th Street.",
                            @"date" : [formatter dateFromString:@"5/25/2015 9:15 PM"],
                            @"type" : @"assignment",
                            @"notificationData" : @{
                                    @"assignment_id" : @"55637a4831c804d53117e727"
                                    }},
                          
                          @{@"title" : @"Photo used",
                            @"notificationDescription" : @"WFLA downloaded your content and may use it soon in their reporting. WFLA downloaded your content and may use it soon in their reporting. WFLA downloaded your content and may use it soon in their reporting.",
                            @"date" : [formatter dateFromString:@"5/25/2015 9:15 PM"],
                            @"type" : @"use",
                            @"notificationData" : @{
                                    @"gallery_id" : @"123asdbasd1254",
                                    @"outlet" : @"wfla"
                                    },
                            },
                          @{@"title" : @"New Assignment",
                            @"event" : @"St. Patrick's Day Parade",
                            @"notificationDescription" : @"The parade has started heading north from 5th Avenue and 44th Street.",
                            @"date" : [formatter dateFromString:@"5/25/2015 9:15 PM"],
                            @"type" : @"assignment",
                            @"notificationData" : @{
                                    @"assignment_id" : @"123asdbasd1254"
                                    }},
                          @{@"title" : @"Photo used",
                            @"notificationDescription" : @"WFLA downloaded your content and may use it soon in their reporting",
                            @"date" : [formatter dateFromString:@"5/25/2015 9:15 PM"],
                            @"type" : @"use",
                            @"notificationData" : @{
                                    @"gallery_id" : @"123asdbasd1254",
                                    @"outlet" : @"wfla"
                                    },
                            },
                          @{@"title" : @"New Assignment",
                            @"event" : @"St. Patrick's Day Parade",
                            @"notificationDescription" : @"The parade has started heading north from 5th Avenue and 44th Street.",
                            @"date" : [formatter dateFromString:@"5/25/2015 9:15 PM"],
                            @"type" : @"assignment",
                            @"notificationData" : @{
                                    @"assignment_id" : @"123asdbasd1254"
                                    }},
                          
                          @{@"title" : @"Photo used",
                            @"notificationDescription" : @"WFLA downloaded your content and may use it soon in their reporting",
                            @"date" : [formatter dateFromString:@"5/25/2015 9:15 PM"],
                            @"type" : @"use",
                            @"notificationData" : @{
                                    @"gallery_id" : @"123asdbasd1254",
                                    @"outlet" : @"wfla"
                                    },
                            }
                          
                          
                          ];
    
    for(NSDictionary *data in someData ){
        
        FRSNotification *not = [[FRSNotification alloc] init];
        
        not.title = data[@"title"];
        not.title = data[@"title"];
        not.notificationDescription = data[@"notificationDescription"];
        not.date = data[@"date"];
        not.notificationData = data[@"notificationData"];
        not.type = data[@"type"];
        
        if([not.type isEqualToString:@"assignment"]){
            not.event = data[@"event"];
        }
        
        [_notifications addObject:not];

    }
    
    
    /** TEMPORARY */

    
//    [self updateNotifications];

    
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

#pragma mark - Notification API

/*
** Grab notifications for user and populate
*/

- (void)updateNotifications{
    

    [[FRSDataManager sharedManager] getNotificationsForUser:^(id responseObject, NSError *error) {
        if (!error) {
            
            self.notifications = responseObject;
            
            [[self tableView] reloadData];
            
        }
        
    }];
    

}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notifications count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // since there is a section for every story
    // and just one story per section
    // the section will tell us the "row"
    // NSUInteger index = indexPath.section;
    
    //Get the notification from the data with index
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellIdentifier forIndexPath:indexPath];
    
    //Set Values from notificaiton
    cell.title.text = notification.title;
    cell.eventName.text = notification.event;
    cell.notificationDescription.text = notification.notificationDescription;
    cell.timeElapsed.text = [MTLModel relativeDateStringFromDate:notification.date];
    
    //Check if assignment, then check if the assignment has expired
    if([notification.type isEqualToString:@"assignment"]){
        
        [cell.firstButton setTitle:@"View Assignment" forState:UIControlStateNormal];
        
        [cell.secondButton setTitle:@"Navigate" forState:UIControlStateNormal];
        
        //25 from the storyboard constraint constant
        cell.constraintNotificationDescription.constant = 25.0f;
        
    }
    else if([notification.type isEqualToString:@"use"]){

        cell.constraintNotificationDescription.constant = 3.0f;
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png",notification. notificationData[@"outlet"]];
        
        if([UIImage imageNamed:imageName]) [[cell image] setImage:[UIImage imageNamed:imageName]];
    
    }
    
    //UI Styling
    cell.firstButton.layer.cornerRadius = 3;
    cell.secondButton.layer.cornerRadius = 3;
    
    cell.firstButton.clipsToBounds = YES;
    cell.secondButton.clipsToBounds = YES;

    cell.firstButton.layer.borderWidth = 1.0;
    cell.secondButton.layer.borderWidth = 1.0;
    
    cell.firstButton.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:.12] CGColor];
    cell.secondButton.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:.12] CGColor];

    cell.firstButton.titleEdgeInsets = UIEdgeInsetsMake(30.0f, 30.0f, 30.0f, 30.0f);
    cell.secondButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 30.0f, 0.0f, 30.0f);
    
    
    return cell;
}

#pragma mark - UITableViewDelegate and Actions


- (IBAction)firstButton:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    //Check the notificaiton type
    if([notification.type isEqualToString:@"assignment"]){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getAssignment:notification.notificationData[@"assignment_id"] withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                
                [tabBarController setSelectedIndex:3];
                
                AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                
                assignmentVC.currentAssignment = responseObject;
                
            }
            
        }];
        
    }
    else if([notification.type isEqualToString:@"use"]){
        
    }
    else if([notification.type isEqualToString:@"social"]){
        
    }


}

- (IBAction)secondButton:(id)sender {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     UITableViewCell *tableViewCellHeader = [[UITableViewCell alloc] init];
    
    return tableViewCellHeader;
}


@end
