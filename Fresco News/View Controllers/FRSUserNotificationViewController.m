//
//  FRSUserNotificationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationViewController.h"

#import "FRSDefaultNotificationTableViewCell.h"
#import "FRSTextNotificationTableViewCell.h"
#import "FRSAssignmentNotificationTableViewCell.h"
#import "FRSProfileViewController.h"
#import "FRSCameraViewController.h"
#import "FRSTabBarController.h"
#import "FRSAppDelegate.h"
#import "FRSAssignment.h"
#import "FRSDebitCardViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSTaxInformationViewController.h"

@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation FRSUserNotificationViewController

-(instancetype)init {
    self = [super init];
    
    if (self) {
        self.tabBarController.tabBarItem.title = @"";
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self saveLastOpenedDate];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}

-(void)saveLastOpenedDate {
    NSDate *today = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"notification-date"];
}


#pragma mark - UI

-(void)configureUI {
    [self configureNavigationBar];
    [self configureTableView];
    [self registerNibs];
}

-(void)configureNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    self.navigationItem.title = @"ACTIVITY";
    
    UIBarButtonItem *userIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile-icon-light"] style:UIBarButtonItemStylePlain target:self action:@selector(returnToProfile)];
    userIcon.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = userIcon;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

-(void)configureTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-49)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    
    [self.view addSubview:self.tableView];
}

-(void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSDefaultNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"notificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTextNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"textNotificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAssignmentNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"assignmentNotificationCell"];
}



#pragma mark - Actions 

-(void)segueToUser:(FRSUser *)user {
    
    FRSProfileViewController *profileVC = [[FRSProfileViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:profileVC animated:YES];
}


-(void)segueToAssignmentWithID:(NSString *)assignmentID {
    
    FRSAssignmentsViewController *assignmentsVC = [[FRSAssignmentsViewController alloc] initWithActiveAssignment:assignmentID];
    [self.navigationController pushViewController:assignmentsVC animated:YES];
}

-(void)segueToTaxInfo {
    
    FRSTaxInformationViewController *taxInfoVC = [[FRSTaxInformationViewController alloc] init];
    [self.navigationController pushViewController:taxInfoVC animated:YES];
}

-(void)segueToBankInfo {

    FRSDebitCardViewController *debitCardVC = [[FRSDebitCardViewController alloc] init];
    debitCardVC.shouldDisplayBankViewOnLoad = YES;
    [self.navigationController pushViewController:debitCardVC animated:YES];
}

-(void)segueToDebitCard {
    
    FRSDebitCardViewController *debitCardVC = [[FRSDebitCardViewController alloc] init];
    [self.navigationController pushViewController:debitCardVC animated:YES];
}

-(void)segueToCamera {
    
    //FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo selectedAssignment:assignment];
    FRSCameraViewController *camVC = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    [navigationController pushViewController:camVC animated:NO];
    [navigationController setNavigationBarHidden:YES];
    
    [self presentViewController:navigationController animated:YES completion:nil];

}

-(void)returnToProfile {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateTabBarToUser];
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0: {
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text = @"Omar Elfanek";
            cell.bodyLabel.text  = @"Followed you.";
            cell.count = 5;
            cell.image.image = [UIImage imageNamed:@"apple-user-byrn"];
            
            [cell configureCell];
            return cell;

        } break;
            
        case 1: {
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text = @"Today in News";
            cell.bodyLabel.text  = @"My money's in that office, right? If she start giving me some bullshit about it ain't there, and we got to go.";
            cell.followButton.alpha = 0;
            cell.image.image = [UIImage imageNamed:@"apple-story-2"];
            
            [cell configureCell];
            
            return cell;
            
        } break;
            
        case 2: {
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text = @"You have $20 expiring soon";
            cell.bodyLabel.text  = @"Add a card by Tuesday to get paid";
            cell.followButton.alpha = 0;
            
            [cell configureCell];
            
            return cell;

            
        } break;
            
        case 3: {
            
            NSString *cellIdentifier = @"textNotificationCell";
            FRSTextNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.bodyLabel.text  = @"BREAKING: Do you see any Teletubbies in here? Do you see a slender plastic tag clipped to my shirt with my name printed on it? Do you see a little Asian child with a blank expression on his face sitting outside on a mechanical helicopter that shakes when you put quarters in it? No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.";
            
            [cell configureCell];
            return cell;
            
        } break;
            
        case 4: {
            
            NSString *cellIdentifier = @"assignmentNotificationCell";
            FRSAssignmentNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text  = @"Assignment: Raining Figs Over Tennessee";
            cell.bodyLabel.text = @"Now that there is the Tec-9, a crappy spray gun from South Miami. This gun is advertised as the most popular gun. This should eventually tuncate after going over three lines maybe let's try and see if it truncates.";
            cell.backgroundColor = [UIColor frescoBackgroundColorDark];
            
            [cell configureCell];
            return cell;
            
        } break;
            
        case 5: {
           
            NSString *cellIdentifier = @"assignmentNotificationCell";
            FRSAssignmentNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text  = @"Assignment: Fire on fire";
            cell.bodyLabel.text = @"Alcatra ham brisket tail filet mignon. Ball tip bresaola biltong, corned beef andouille short ribs pork belly cupim flank. Spare ribs pancetta ham hock ham pig beef ribs frankfurter tongue shankle tenderloin sirloin, flank rump.";
            cell.backgroundColor = [UIColor frescoBackgroundColorDark];
            [cell.actionButton setImage:[UIImage imageNamed:@"directions-24"] forState:UIControlStateNormal];

            [cell configureCell];
            return cell;
            
        } break;
            
        default:
            break;
    }
    
    
//    if (cell.isRead) {
//        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
//    }
    
    
    UITableViewCell *cell;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateTabBarToUser];
    
    if (indexPath.row == 0) {
        [self segueToUser:[[FRSAPIClient sharedClient] authenticatedUser]];
    }
    
    if (indexPath.row == 2) {
        [self segueToDebitCard];
    }
    
    if (indexPath.row == 4) {

        [self segueToCamera];
    }
    
    if (indexPath.row == 5) {
        
        [self segueToAssignmentWithID:@"xLJE0QzW1G5B"]; //
    }
}

-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}














@end
