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
#import "FRSUser.h"
#import "GalleryViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FRSRootViewController.h"

static NSString *NotificationCellIdentifier = @"NotificationCell";

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *notifications;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAssignmentDescription;

@end

@implementation NotificationsViewController

- (id)init{
    
    if (self = [super init]) {
        self.notifications = [[NSMutableArray alloc] init];
    }

    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setFrescoNavigationBar];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 119;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    [[FRSDataManager sharedManager] getNotificationsForUser:^(id responseObject, NSError *error) {
        if (!error) {
            
            if(responseObject == nil || [responseObject count] == 0){
                
                UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 150, 100)];
                
                label.text = @"No Notifications";
                
                label.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
                
                [label sizeToFit];
                
                label.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
                
                [self.view addSubview:label];
                
                self.tableView.hidden = YES;
                
            }
            else{
                
                self.notifications = [NSMutableArray arrayWithArray:responseObject];
                
                [[self tableView] reloadData];
                
            }
            
        }
        
    }];
    
    
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:NO];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
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

- (void)exitNotificationView{

    [self.navigationController hideNotifications];

}

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
    cell.notificationDescription.text = notification.body;
    cell.timeElapsed.text = [MTLModel relativeDateStringFromDate:notification.date];
    
    if(notification.seen == false){
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"faf4e5"];
    }
    
    //Check if assignment, then check if the assignment has expired
    if([notification.type isEqualToString:@"assignment"]){
        
        [cell.firstButton setTitle:@"View Assignment" forState:UIControlStateNormal];
        
        [cell.secondButton setTitle:@"Navigate" forState:UIControlStateNormal];
        
        //25 from the storyboard constraint constant
        cell.constraintNotificationDescription.constant = 25.0f;
        
    }
    else if([notification.type isEqualToString:@"use"]){

        cell.constraintNotificationDescription.constant = 3.0f;
        
        cell.secondButton.hidden = YES;
        
        if([notification.meta[@"icon"] isKindOfClass:[NSString class]]){
            
            [cell.image setImageWithURL:[NSURL URLWithString:notification.meta[@"icon"]] placeholderImage:[UIImage imageNamed:@"assignmentWarningIcon"]];
        
        }
    
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
    
    return cell;
}

#pragma mark - UITableViewDelegate and Actions

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FRSNotification *notification = [self.notifications objectAtIndex:[indexPath item]];

        [[FRSDataManager sharedManager] deleteNotification:notification.notificaitonId withResponseBlock:^(id responseObject, NSError *error) {
            
            if(!error){
                
                [self.notifications removeObjectAtIndex:[indexPath item]];
                
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            }
            
        }];

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *tableViewCellHeader = [[UITableViewCell alloc] init];
    
    return tableViewCellHeader;
}

/*
** Action for second buttons on notification cells i.e. view assignmnet, view gallery
*/

- (IBAction)firstButton:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    if(notification.seen == false){
        
        [[FRSDataManager sharedManager] setNotificationSeen:notification.notificaitonId withResponseBlock:nil];
        
    }
    
    //Check the notificaiton type
    if([notification.type isEqualToString:@"assignment"] && notification.meta[@"assignment"] != nil){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getAssignment:notification.meta[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                if(responseObject != nil){
                    
                    FRSAssignment *assignment = (FRSAssignment *) responseObject;
                    
                    //Check if the assignment has expired
                    if(([assignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
                
                        [self exitNotificationView];
                        
                        UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                        
                        AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                        
                        [assignmentVC setCurrentAssignment:responseObject navigateTo:NO];
                        
                        [tabBarController setSelectedIndex:3];
                        
                        
                    }
                    else{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Assignment Expired"
                                                                        message:@"This assignment has expired already!"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                        [alert show];
                    
                    
                    }
                    
                }
            }
            
        }];
        
    }
    else if([notification.type isEqualToString:@"use"] || [notification.type isEqualToString:@"breaking"] ){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getGallery:notification.meta[@"gallery"] WithResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                if(((FRSGallery *)responseObject).galleryID != nil){
                
                    //Retreieve Gallery View Controller from storyboard
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    
                    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
                    
                    [galleryView setGallery:responseObject];
           
                    [self.navigationController pushViewController:galleryView animated:YES];
                        
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gallery Unavailable"
                                                                    message:@"We couldn't find this gallery!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                    [alert show];
                
                }
                
            }
            
        }];
        
    }
    else if([notification.type isEqualToString:@"social"]){
        
    }

}

/*
** Action for second buttons on notification cells i.e. navigate, outlet
*/

- (IBAction)secondButton:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    if(notification.seen == false){
        
        [[FRSDataManager sharedManager] setNotificationSeen:notification.notificaitonId withResponseBlock:nil];
        
    }
    
    //Check the notificaiton type
    if([notification.type isEqualToString:@"assignment"] && notification.meta[@"assignment"] != nil){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getAssignment:notification.meta[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                FRSAssignment *assignment = (FRSAssignment *) responseObject;
                
                //Check if the assignment has expired
                if(([assignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
                    
                    [self exitNotificationView];
                    
                    UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    
                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                    
                    [tabBarController setSelectedIndex:3];
                    
                    [assignmentVC setCurrentAssignment:assignment navigateTo:YES];
                
                
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Assignment Expired"
                                                                    message:@"This assignment has expired already!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }

            }
            
        }];
        
    }
    else if([notification.type isEqualToString:@"use"]){
        
    }
    else if([notification.type isEqualToString:@"social"]){
        
    }
    
}


@end
