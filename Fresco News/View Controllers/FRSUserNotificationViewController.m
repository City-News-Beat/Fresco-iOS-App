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
#import "FRSGalleryExpandedViewController.h"

@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *payload;

@property BOOL isSegueingToGallery;
@property BOOL isSegueingToStory;

@end

@implementation FRSUserNotificationViewController

-(instancetype)init {
    self = [super init];
    
    if (self) {
        self.tabBarController.tabBarItem.title = @"";
        
        self.payload = [[NSDictionary alloc] init];
        
        
        NSArray *post_ids    = @[@"LJx3jeQg1kpN", @"5xQ0WoLw0lX9", @"EL2Z3meP39jR", @"6DrY8KYM1KBP", @"Qz7J07vY8dDZ"];
        NSArray *gallery_ids = @[@"YQVr1ElM05qP", @"dYOJ8vjz8ML4", @"YZb485DD3xoV", @"gBbY3oPB8PM6"];
        NSString *gallery_id = @"arYd0y5Q0Dp5";
        NSString *story_id   = @"7mr93zRx3BlY";
        NSString *empty = @"";
        NSArray *user_ids = @[@"ewOo1Pr8KvlN", @"2vRW0Na8oEgQ", @"Ym4x8rK0Jjpd"];

        NSString *assignment_id = @"xLJE0QzW1G5B";

        NSString *outlet_id = @"7ewm8YP3GL5x";
        
        NSString *body = @"BREAKING: Bernie Sanders wins South Carolina Democratic primary, with an unheard of 130% of the popular vote";


        self.payload = @{
                         
                         photoOfDayNotification : post_ids,
                         todayInNewsNotification : gallery_ids,
                         userNewsGalleryNotification : gallery_id,
                         userNewsStoryNotification : story_id,
                         userNewsCustomNotification : body,
                         
                         followedNotification : user_ids,
                         likedNotification : @[user_ids, gallery_id],
                         repostedNotification : @[user_ids, gallery_id],
                         commentedNotification : @[user_ids, gallery_id],
                         
                         newAssignmentNotification : assignment_id,
                         
                         purchasedContentNotification : @[outlet_id, post_ids],
                         paymentExpiringNotification : empty,
                         paymentSentNotification: empty,
                         paymentDeclinedNotification : empty,
                         taxInfoRequiredNotification : empty,
                         taxInfoProcessedNotification : empty,
                         taxInfoDeclinedNotification : empty,
                         taxInfoProcessedNotification : empty,
                         
                         };
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
    self.navigationItem.title = @"ACTIVITY";
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.isSegueingToGallery = NO;
    self.isSegueingToStory = NO;
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
    self.tableView.estimatedRowHeight = 100;
    
    [self.view addSubview:self.tableView];
}

-(void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSDefaultNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"notificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTextNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"textNotificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAssignmentNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"assignmentNotificationCell"];
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0:
            return 64;
            break;
        case 1:
            return 64;
            break;
        case 2:
            return 84;
            break;
        case 3:
            return 104;
            break;
        case 4:
            return 104;
            break;
        case 9:
            return 84;
            break;
        case 10:
            return 104;
            break;
        case 11:
            return 84;
            break;
        
        default:
            break;
    }

    return 64;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    
//    NSString *cellKey = @""; //set from payload
    
    switch (indexPath.row) {
        case 0: {
            
//            cellKey = @"user-social-followed";
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];            
            NSArray *users = [self.payload objectForKey:@"user-social-followed"];
            cell.count = users.count;
            
            [cell configureUserFollowNotificationWithID:[[self.payload objectForKey:@"user-social-followed"] objectAtIndex:1]];
            
            return cell;
        } break;
            
        case 1: {
            
//            cellKey = @"user-social-liked";
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            NSArray *users = [self.payload objectForKey:@"user-social-followed"];
            cell.count = users.count;
            
            [cell configureUserLikeNotificationWithUserID:[[self.payload objectForKey:@"user-social-followed"] objectAtIndex:0] galleryID:[self.payload objectForKey:@"user-social-liked"]];
        
            return cell;
        } break;
            
        case 2: {
            
//            cellKey = @"user-news-story";
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [cell configureFeaturedStoryCellWithStoryID:[self.payload objectForKey:@"user-news-story"]];
            return cell;
            
        } break;
            
        case 3: {
            
//            cellKey = @"user-dispatch-new-assignment";
            
            NSString *cellIdentifier = @"assignmentNotificationCell";
            FRSAssignmentNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [cell configureAssignmentCellWithID:[self.payload objectForKey:@"user-dispatch-new-assignment"]];
            
            return cell;
        } break;
            
        case 4: {
            
//            cellKey = @"user-dispatch-new-assignment";
            
            NSString *cellIdentifier = @"assignmentNotificationCell";
            FRSAssignmentNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [cell configureCameraCellWithAssignmentID:[self.payload objectForKey:@"user-dispatch-new-assignment"]];
            
            return cell;
            
        } case 5: {
            
//            cellKey = @"user-social-reposted";
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            NSArray *users = [self.payload objectForKey:@"user-social-followed"];
            cell.count = users.count;
            
            [cell configureUserRepostNotificationWithUserID:[[self.payload objectForKey:@"user-social-followed"] objectAtIndex:2] galleryID:[self.payload objectForKey:@"user-social-liked"]];
            return cell;
            
        } case 6: {
            
//            cellKey = @"user-social-commented";
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            NSArray *users = [self.payload objectForKey:@"user-social-followed"];
            cell.count = users.count;
            [cell configureUserCommentNotificationWithUserID:[[self.payload objectForKey:@"user-social-followed"] objectAtIndex:0] commentID:nil];
            return cell;
        
        } case 7: {
            
//            cellKey = @"user-social-commented";
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            NSArray *users = [self.payload objectForKey:@"user-social-followed"];
            cell.count = users.count;
            [cell configureUserMentionCommentNotificationWithUserID:[[self.payload objectForKey:@"user-social-followed"] objectAtIndex:1] commentID:nil];
            return cell;
            
        } case 8: {
            
//            cellKey = @"user-social-commented";

            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            NSArray *users = [self.payload objectForKey:@"user-social-followed"];
            cell.count = users.count;
            [cell configureUserMentionGalleryNotificationWithUserID:[[self.payload objectForKey:@"user-social-followed"] objectAtIndex:0] galleryID:nil];
            return cell;
            
        } case 9: {
            
//            cellKey = @"user-news-custom-push";
            
            NSString *cellIdentifier = @"textNotificationCell";
            FRSTextNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [cell configureTextCell:[self.payload objectForKey:@"user-news-custom-push"]];
            return cell;

        } case 10: {
            
//            Today in News
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [cell configureUserMentionGalleryNotificationWithUserID:nil galleryID:nil];

            return cell;
        }
    

        default:
            break;
    }

    UITableViewCell *cell;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"INDEXPATH: %ld", (long)indexPath.row);
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateTabBarToUser];
    
    
    switch (indexPath.row) {
        case 0:
            [self segueToUser:[[self.payload objectForKey:followedNotification] objectAtIndex:1]];
            break;
        
        case 1:
            [self segueToGallery:[self.payload objectForKey:userNewsGalleryNotification]];
            break;
            
        case 2:
            [self segueToStory:[self.payload objectForKey:userNewsStoryNotification]];
            break;
            
        case 3:
            [self segueToAssignmentWithID:[self.payload objectForKey:newAssignmentNotification]];
            break;
            
        case 4:
            [self segueToCameraWithAssignmentID:[self.payload objectForKey:newAssignmentNotification]];
            break;
        
        case 5:
            [self segueToGallery:[self.payload objectForKey:userNewsGalleryNotification]];
            break;
            
        case 6:
            [self segueToGallery:[self.payload objectForKey:userNewsGalleryNotification]];
            break;
            
        case 7:
            [self segueToGallery:[self.payload objectForKey:userNewsGalleryNotification]];
            break;
        
        case 8:
            [self segueToGallery:[self.payload objectForKey:userNewsGalleryNotification]];
            break;
            
        case 9:
//            [self segueHome];
            break;
            
        case 10:
            [self segueToTodayInNews:[self.payload objectForKey:todayInNewsNotification]];
            break;

        default:
            break;
    }
    
}

#pragma mark - Actions

-(void)popViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
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



-(void)returnToProfile {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateTabBarToUser];
}











@end
