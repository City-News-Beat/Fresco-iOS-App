//
//  NotificationsViewController.m
//  FrescoNews
//
//  Created by Fresco News on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NotificationsViewController.h"
#import "FRSRootViewController.h"
#import "FRSAlertViewManager.h"
#import "FRSDataManager.h"
#import "FRSUser.h"
#import "FRSNotification.h"
#import "AssignmentsViewController.h"
#import "GalleryViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NotificationCell.h"
#import "UIViewController+Additions.h"
#import "ProfilePaymentSettingsViewController.h"

static NSString *NotificationCellIdentifier = @"NotificationCell";

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *notifications;

@property (nonatomic, assign) BOOL disableEndlessScroll;

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.showsVerticalScrollIndicator = NO;

    #warning Fix this
    //Endless scroll handler
//    [self.tableView addInfiniteScrollingWithActionHandler:^{
//        
//        if(!self.disableEndlessScroll) {
//        
//            // append data to data source, insert new cells at the end of table view
//            NSNumber *num = [NSNumber numberWithInteger:[self.notifications count]];
//            
//            //Make request for more posts, append to galleries array
//            [[FRSDataManager sharedManager] getNotificationsForUser:num withResponseBlock:^(id responseObject, NSError *error) {
//                if (!error) {
//                    
//                    if ([responseObject count] > 0) {
//                        
//                        [self.notifications addObjectsFromArray:responseObject];
//                        
//                        [self.tableView reloadData];
//                        
//                        
//                    }
//                    else
//                        self.disableEndlessScroll = YES;
//                    
//                    [self.tableView.infiniteScrollingView stopAnimating];
//                    
//                }
//            }];
//            
//        } else {
//            [self.tableView.infiniteScrollingView stopAnimating];
//        }
//        
//    }];
    
    [[FRSDataManager sharedManager] getNotificationsForUser:0 withResponseBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            if(responseObject == nil || [responseObject count] == 0){
                
                UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 150, 100)];
                
                label.text = @"No Notifications";
                
                label.font= [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:20.0f];
                
                [label sizeToFit];
                
                label.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
                
                [self.view addSubview:label];
                
                self.tableView.hidden = YES;
                
            } else {
                
                self.notifications = [NSMutableArray arrayWithArray:responseObject];
                
                [[self tableView] reloadData];
            }
            
        }
        
    }];
    
    
}


- (void)setAllNotificaitonsSeen {
    
    for(FRSNotification *notification in self.notifications) {
        
        if (!notification.seen)
            [[FRSDataManager sharedManager] setNotificationSeen:notification.notificaitonId withResponseBlock:nil];
        
    }
}

- (void)exitNotificationView{

    [self hideNotifications:nil];
    
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

    //Get the notification from the data with index
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellIdentifier forIndexPath:indexPath];
    
    [cell setNotification:notification];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate and Actions

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        FRSNotification *notification = [self.notifications objectAtIndex:[indexPath item]];
//
//        [[FRSDataManager sharedManager] deleteNotification:notification.notificaitonId withResponseBlock:^(id responseObject, NSError *error) {
//            
//            if(!error){
//                
//                [self.notifications removeObjectAtIndex:[indexPath item]];
//                
//                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            
//            }
//            
//        }];
//
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

/*
** Action for second buttons on notification cells i.e. view assignmnet, view gallery
*/

- (IBAction)firstButton:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    //Check the notificaiton type
    if([notification.type isEqualToString:@"assignment"] && notification.meta[@"assignment"] != nil){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getAssignment:notification.meta[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                if(responseObject != nil){
                    
                    FRSAssignment *assignment = (FRSAssignment *) responseObject;
                    
                    //Check if the assignment has expired
                    if(([assignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
                
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_VIEW_DISMISS object:nil];
                        
                        UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                        
                        AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                        
                        [assignmentVC setCurrentAssignment:responseObject navigateTo:NO present:YES withAnimation:NO];
                        
                        if(tabBarController.selectedIndex != 3)
                            [tabBarController setSelectedIndex:3];
                        
                        
                    }
                    else{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASSIGNMENT_EXPIRED_TITLE
                                                                        message:ASSIGNMENT_EXPIRED_MSG
                                                                       delegate:nil
                                                              cancelButtonTitle:DISMISS
                                                              otherButtonTitles:nil];
                        [alert show];
                    
                    
                    }
                    
                }
            }
            
        }];
        
    }
    else if([notification.type isEqualToString:@"use"] || [notification.type isEqualToString:NOTIF_BREAKING] ){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getGallery:notification.meta[@"gallery"] withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                if(((FRSGallery *)responseObject).galleryID != nil){
                
                    //Retreieve Gallery View Controller from storyboard
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    
                    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
                    
                    [galleryView setGallery:responseObject];
           
                    [self.navigationController pushViewController:galleryView animated:YES];
                        
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:GALLERY_UNAVAILABLE_TITLE
                                                                    message:GALLERY_UNAVAILABLE_MSG
                                                                   delegate:nil
                                                          cancelButtonTitle:DISMISS
                                                          otherButtonTitles:nil];
                    [alert show];
                
                }
                
            }
            
        }];
        
    }
    else if([notification.type isEqualToString:@"payment"]){
        
        ProfilePaymentSettingsViewController *paymentSettings = [[ProfilePaymentSettingsViewController alloc] init];
        
        [self.navigationController pushViewController:paymentSettings animated:YES];
        
    }

}

/*
** Action for second buttons on notification cells i.e. navigate, outlet
*/

- (IBAction)secondButton:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    FRSNotification *notification = [[self notifications] objectAtIndex:[indexPath item]];
    
    //Check the notificaiton type
    if([notification.type isEqualToString:@"assignment"] && notification.meta[@"assignment"] != nil){
        
        //Get assignment and navigate to on assignments view
        [[FRSDataManager sharedManager] getAssignment:notification.meta[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                FRSAssignment *assignment = (FRSAssignment *) responseObject;
                
                //Check if the assignment has expired
                if(([assignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_VIEW_DISMISS object:nil];
                    
                    UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    
                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                    
                    [tabBarController setSelectedIndex:3];
                    
                    [assignmentVC setCurrentAssignment:assignment navigateTo:YES present:YES withAnimation:NO];
                
                
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASSIGNMENT_EXPIRED_TITLE
                                                                    message:ASSIGNMENT_EXPIRED_MSG
                                                                   delegate:nil
                                                          cancelButtonTitle:DISMISS
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
