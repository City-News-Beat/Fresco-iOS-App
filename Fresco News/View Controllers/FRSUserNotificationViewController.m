//
//  FRSUserNotificationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationViewController.h"

#import "FRSAppDelegate.h"
#import "FRSTabBarController.h"

#import "FRSAssignmentNotificationTableViewCell.h"
#import "FRSDefaultNotificationTableViewCell.h"
#import "FRSTextNotificationTableViewCell.h"

#import "FRSCameraViewController.h"
#import "FRSProfileViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSTaxInformationViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"

#import "FRSAssignment.h"
#import "FRSAlertView.h"

#import <Haneke/Haneke.h>

#import "FRSAwkwardView.h"


@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource, FRSExternalNavigationDelegate>

@property (strong, nonatomic) NSDictionary *payload;
@property (strong, nonatomic) NSArray *feed;
@property BOOL isSegueingToGallery;
@property BOOL isSegueingToStory;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) NSInteger loadedNotificationCount;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *spinner;

@end

@implementation FRSUserNotificationViewController

NSString * const TEXT_ID       = @"textNotificationCell";
NSString * const DEFAULT_ID    = @"notificationCell";
NSString * const ASSIGNMENT_ID = @"assignmentNotificationCell";

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
        NSArray *user_ids = @[@"2vRW0Na8oEgQ", @"ewOo1Pr8KvlN", @"Ym4x8rK0Jjpd"];

        NSString *assignment_id = @"xLJE0QzW1G5B";

        NSString *outlet_id = @"7ewm8YP3GL5x";
        
        NSString *body = @"BREAKING: Bernie Sanders wins South Carolina Democratic primary, with an unheard of 130% of the popular vote";


        self.payload = @{
                         
                         //photoOfDayNotification : post_ids,
                         todayInNewsNotification : gallery_ids,
                         userNewsGalleryNotification : gallery_id,
                         userNewsStoryNotification : story_id,
                         userNewsCustomNotification : body,
                         
                         followedNotification : user_ids,
                         likedNotification : @{@"user_ids" : user_ids, @"gallery_id": gallery_id},
                         repostedNotification : @{@"user_ids" : user_ids, @"gallery_id": gallery_id},
                         commentedNotification : @{@"user_ids" : user_ids, @"gallery_id": gallery_id},
                         //mentionCommentNotification : @[], //cc: api
                         //mentionGalleryNotification : @[], //cc: api
                         
                         newAssignmentNotification : assignment_id,
                         
                         purchasedContentNotification : @{@"outlet_id" : outlet_id, @"post_ids" : post_ids, @"has_card_": @TRUE},
                         paymentExpiringNotification : empty,
                         paymentSentNotification: empty,
                         paymentDeclinedNotification : empty,
                         taxInfoRequiredNotification : empty,
                         taxInfoProcessedNotification : @NO,
                         taxInfoDeclinedNotification : @YES,
                         taxInfoProcessedNotification : @YES,
                         
                         };
    }
    
    return self;
}

-(void)configureSpinner {
    self.spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.spinner.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.spinner.tintColor = [UIColor frescoOrangeColor];
    [self.spinner setPullProgress:90];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
}

-(void)checkNotifications {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInterface) userInfo:nil repeats:YES];
}

-(void)updateInterface {
    
    if (self.loadedNotificationCount == self.payload.count) {
        [self.timer invalidate];
    }
}


-(void)getNotifications {
    
    [[FRSAPIClient sharedClient] getNotificationsWithCompletion:^(id responseObject, NSError *error) {

        self.feed = [responseObject objectForKey:@"feed"];
        
        [self configureTableView];
        [self registerNibs];
        
        [self.spinner stopLoading];
    }];
}


-(void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    FRSAlertView *alert = [[FRSAlertView alloc] init];
    alert.delegate = self;
    [alert navigateToAssignmentWithLatitude:latitude longitude:longitude];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self getNotifications];
    [self checkNotifications];
    
    [self configureUI];
    
    [self saveLastOpenedDate];
    
    [(FRSTabBarController *)self.tabBarController updateBellIcon:NO];
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
    
    if (self.tabBarController) {
        [(FRSTabBarController *)self.tabBarController updateUserIcon];
    } else {
        FRSTabBarController *tabBarController = (FRSTabBarController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        [tabBarController updateUserIcon];
    }
    
}

-(void)saveLastOpenedDate {
    NSDate *today = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"notification-date"];
}


#pragma mark - UI

-(void)configureUI {
    [self configureNavigationBar];
    [self configureSpinner];
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
    
    
    
    if (self.payload.count == 0) {

        FRSAwkwardView *awkward = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -175/2, self.view.frame.size.height/2 -125/2 -64, 175, 125)];
        [self.tableView addSubview:awkward];
    }
}

-(void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSDefaultNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"notificationCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTextNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"textNotificationCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAssignmentNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"assignmentNotificationCell"];
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.payload.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    
    if ([[cell class] isSubclassOfClass:[FRSDefaultNotificationTableViewCell class]]) {
        FRSDefaultNotificationTableViewCell *defaultCell = (FRSDefaultNotificationTableViewCell *)cell;
        
        return [defaultCell heightForCell];
    }
    
    if ([[cell class] isSubclassOfClass:[FRSAssignmentNotificationTableViewCell class]]) {
        FRSAssignmentNotificationTableViewCell *assignmentCell = (FRSAssignmentNotificationTableViewCell *)cell;
        
        return [assignmentCell heightForCell];
    }
    
    if ([[cell class] isSubclassOfClass:[FRSTextNotificationTableViewCell class]]) {
        FRSTextNotificationTableViewCell *textCell = (FRSTextNotificationTableViewCell *)cell;
        
        return [textCell heightForCell];
    }
    
    
    
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    NSArray *keys = [self.payload allKeys];
    NSString *currentKey = [keys objectAtIndex:indexPath.row];
    
    /*
        Ight so this setup is a tad bit f**ked up. Will need to re-write large portion of this. Good reminder of a situation in which you should trash whats there and start from scratch (if this was started off a dan base)
     */
    
    
    FRSDefaultNotificationTableViewCell *defaultCell = [self.tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
    
    if (!defaultCell) {
        defaultCell = [[FRSDefaultNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DEFAULT_ID];
        [defaultCell configureDefaultCell];
    }
    
    FRSAssignmentNotificationTableViewCell *assignmentCell = [self.tableView dequeueReusableCellWithIdentifier:ASSIGNMENT_ID];
    if (!assignmentCell) {
        assignmentCell = [[FRSAssignmentNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ASSIGNMENT_ID];
        assignmentCell.delegate = self;
    }
    
    FRSTextNotificationTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:TEXT_ID];
    if (!textCell) {
        textCell = [[FRSTextNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TEXT_ID];
    }
    
    
    

    /* NEWS */
    if ([currentKey isEqualToString:photoOfDayNotification]) {
        NSLog(@"PHOTOS OF THE DAY");
    } else if ([currentKey isEqualToString:todayInNewsNotification]) {
        NSLog(@"TODAY IN NEWS");
        [self configureTodayInNews:defaultCell galleryIDs:[self.payload objectForKey:todayInNewsNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsGalleryNotification]) {
        NSLog(@"USER NEWS GALLERY");
        [self configureGalleryCell:defaultCell galleryID:[self.payload objectForKey:userNewsGalleryNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsStoryNotification]) {
        NSLog(@"USER NEWS STORY");
        [self configureStoryCell:defaultCell storyID:[self.payload objectForKey:userNewsStoryNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsCustomNotification]) {
        NSLog(@"USER NEWS CUSTOM");
        [self configureTextCell:textCell text:[self.payload objectForKey:userNewsCustomNotification]];
        return textCell;
        
    /* SOCIAL */
    } else if ([currentKey isEqualToString:followedNotification]) {
        NSLog(@"FOLLOWED");
        [self configureFollowCell:defaultCell userIDs:[self.payload objectForKey:followedNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:likedNotification]) {
        NSLog(@"LIKED");
        [self configureLikeCell:defaultCell userIDs:[[self.payload objectForKey:likedNotification] objectForKey:@"user_ids"] galleryID:[[self.payload objectForKey:likedNotification] objectForKey:@"gallery_id"]];
        return defaultCell;

    } else if ([currentKey isEqualToString:repostedNotification]) {
        NSLog(@"REPOSTED");
        [self configureRepostCell:defaultCell userIDs:[[self.payload objectForKey:repostedNotification] objectForKey:@"user_ids"] galleryID:[[self.payload objectForKey:repostedNotification] objectForKey:@"gallery_id"]];
        return defaultCell;

    } else if ([currentKey isEqualToString:commentedNotification]) {
        NSLog(@"COMMENTED");
        [self configureCommentCell:defaultCell userIDs:[[self.payload objectForKey:commentedNotification] objectForKey:@"user_ids"] galleryID:[[self.payload objectForKey:commentedNotification] objectForKey:@"gallery_id"]];
        return defaultCell;

    }/* else if ([currentKey isEqualToString:mentionCommentNotification]) {
        NSLog(@"MENTION COMMENT");
    } else if ([currentKey isEqualToString:mentionGalleryNotification]) {
        NSLog(@"MENTION GALLERY");
    }*/
    
    /* ASSIGNMENT */
    else if ([currentKey isEqualToString:newAssignmentNotification]) {
        [self configureAssignmentCell:assignmentCell withID:[self.payload objectForKey:newAssignmentNotification]];
        return assignmentCell;
    }
    
    /* PAYMENT */
    else if ([currentKey isEqualToString:purchasedContentNotification]) {
        NSLog(@"PURCHASED CONTENT");

        [self configurePurchasedContentCell:defaultCell outletID:[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"outlet_id"] postID:[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"post_id"] hasPaymentInfo:[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"has_card_"]];
        
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentExpiringNotification]) {
        NSLog(@"PAYMENT EXPIRING");
        [self configurePaymentExpiringCell:defaultCell];
        
    } else if ([currentKey isEqualToString:paymentSentNotification]) {
        NSLog(@"PAYMENT SENT");
        [self configurePaymentSentCell:defaultCell];
        
    } else if ([currentKey isEqualToString:paymentDeclinedNotification]) {
        NSLog(@"PAYMENT DECLINED");
        [self configurePaymentDeclinedCell:defaultCell];
        
    } else if ([currentKey isEqualToString:taxInfoRequiredNotification]) {
        NSLog(@"TAX INFO REQUIRED");
        [self configureTaxInfoRequiredCell:defaultCell];
        
    } else if ([currentKey isEqualToString:taxInfoProcessedNotification]) {
        NSLog(@"TAX INFO PROCESSING");
        [self configureTaxInfoProcessedCell:defaultCell processed:[self.payload objectForKey:taxInfoProcessedNotification]];
        
    } else if ([currentKey isEqualToString:taxInfoDeclinedNotification]) {
        NSLog(@"TAX INFO DECLINED");
        [self configureTaxInfoDeclinedCell:defaultCell];
        
    } else {
        return defaultCell;
    }

    return defaultCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *keys = [self.payload allKeys];
    NSString *currentKey = [keys objectAtIndex:indexPath.row];
    
    /* NEWS */
    if ([currentKey isEqualToString:photoOfDayNotification]) {

    } else if ([currentKey isEqualToString:todayInNewsNotification]) {
        [self segueToTodayInNews:[self.payload objectForKey:todayInNewsNotification]];
        
    } else if ([currentKey isEqualToString:userNewsGalleryNotification]) {
        [self segueToGallery:[self.payload objectForKey:userNewsGalleryNotification]];
        
    } else if ([currentKey isEqualToString:userNewsStoryNotification]) {
        [self segueToStory:[self.payload objectForKey:userNewsStoryNotification]];

    } else if ([currentKey isEqualToString:userNewsCustomNotification]) {
        // Do nothing (for now)
        
    /* SOCIAL */
    } else if ([currentKey isEqualToString:followedNotification]) {
        [self segueToUser:[[self.payload objectForKey:followedNotification] objectAtIndex:0]];
        
    } else if ([currentKey isEqualToString:likedNotification]) {
        [self segueToGallery:[[self.payload objectForKey:likedNotification] objectForKey:@"gallery_id"]];
        
    } else if ([currentKey isEqualToString:repostedNotification]) {
        [self segueToGallery:[[self.payload objectForKey:repostedNotification] objectForKey:@"gallery_id"]];
        
    } else if ([currentKey isEqualToString:commentedNotification]) {
        [self segueToGallery:[[self.payload objectForKey:commentedNotification] objectForKey:@"gallery_id"]];

    }/* else if ([currentKey isEqualToString:mentionCommentNotification]) {
      NSLog(@"MENTION COMMENT");
      } else if ([currentKey isEqualToString:mentionGalleryNotification]) {
      NSLog(@"MENTION GALLERY");
      }*/
    
    /* ASSIGNMENT */
    else if ([currentKey isEqualToString:newAssignmentNotification]) {
        [self segueToAssignmentWithID:[self.payload objectForKey:newAssignmentNotification]];
    }
    
    /* PAYMENT */
    else if ([currentKey isEqualToString:purchasedContentNotification]) {
        [self segueToPost:[[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"post_ids"] objectAtIndex:0]];
        
    } else if ([currentKey isEqualToString:paymentExpiringNotification]) {
        [self segueToDebitCard];
        
    } else if ([currentKey isEqualToString:paymentSentNotification]) {
        
        
    } else if ([currentKey isEqualToString:paymentDeclinedNotification]) {
        [self segueToDebitCard];

    } else if ([currentKey isEqualToString:taxInfoRequiredNotification]) {
        [self segueToTaxInfo];
        
    } else if ([currentKey isEqualToString:taxInfoProcessedNotification]) {
        // do nothing
        
    } else if ([currentKey isEqualToString:taxInfoDeclinedNotification]) {
        [self segueToTaxInfo];
    } else {

    
    }
    
    
    
    
}


#pragma mark - Cell Configuration

#pragma mark - News
-(void)configureTodayInNews:(FRSDefaultNotificationTableViewCell *)cell galleryIDs:(NSArray*)galleryIDs {
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Today in News";
    cell.bodyLabel.numberOfLines = 3;
//    cell.bodyLabel.text = @"\n\n\n";
    
    [[FRSAPIClient sharedClient] getGalleryWithUID:[galleryIDs objectAtIndex:0] completion:^(id responseObject, NSError *error) {

        cell.bodyLabel.text = [responseObject objectForKey:@"caption"];
        
        NSURL *galleryURL = [NSURL URLWithString:[[[responseObject objectForKey:@"posts"] objectAtIndex:1] objectForKey:@"image"]];
        [cell.image hnk_setImageFromURL:galleryURL];
        
        self.loadedNotificationCount++;
        
    }];
}


-(void)configureGalleryCell:(FRSDefaultNotificationTableViewCell *)cell galleryID:(NSString *)galleryID {
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Featured Gallery";
//    cell.bodyLabel.text = @"\n";
    cell.bodyLabel.numberOfLines = 3;
    
    [[FRSAPIClient sharedClient] getGalleryWithUID:galleryID completion:^(id responseObject, NSError *error) {
       
        cell.bodyLabel.text = [responseObject objectForKey:@"caption"];
        
        NSURL *galleryURL = [NSURL URLWithString:[[[responseObject objectForKey:@"posts"] objectAtIndex:1] objectForKey:@"image"]];
        [cell.image hnk_setImageFromURL:galleryURL];
        self.loadedNotificationCount++;
    }];
}


-(void)configureStoryCell:(FRSDefaultNotificationTableViewCell *)cell storyID:(NSString *)storyID {
    [cell configureDefaultCell];
    
//    cell.titleLabel.text = @"\n";
//    cell.bodyLabel.text = @"\n";
    
    [[FRSAPIClient sharedClient] getStoryWithUID:storyID completion:^(id responseObject, NSError *error) {
        
        cell.titleLabel.text = [NSString stringWithFormat:@"Featured Story: %@", [responseObject objectForKey:@"title"]];
        cell.bodyLabel.text = [responseObject objectForKey:@"caption"];
        cell.bodyLabel.numberOfLines = 3;
        cell.titleLabel.numberOfLines = 2;
        
        if([responseObject objectForKey:@"thumbnails"] != [NSNull null]){
            NSURL *avatarURL = [NSURL URLWithString:[[[responseObject objectForKey:@"thumbnails"] objectAtIndex:0] objectForKey:@"image"]];
            [cell.image hnk_setImageFromURL:avatarURL];
        }
        self.loadedNotificationCount++;
    }];
}

-(void)configureTextCell:(FRSTextNotificationTableViewCell *)textCell text:(NSString *)text {
    textCell.label.numberOfLines = 0;
    textCell.label.text = text;
}


#pragma mark - Assignments
-(void)configureAssignmentCell:(FRSAssignmentNotificationTableViewCell *)assignmentCell withID:(NSString *)assignmentID {
    
    assignmentCell.titleLabel.numberOfLines = 0;
    assignmentCell.bodyLabel.numberOfLines  = 3;
    assignmentCell.actionButton.tintColor = [UIColor blackColor];
    
    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
        
        assignmentCell.titleLabel.text = [responseObject objectForKey:@"title"];
        assignmentCell.bodyLabel.text = [responseObject objectForKey:@"caption"];
        
        self.loadedNotificationCount++;
    }];
}


#pragma mark - Social

-(void)configureFollowCell:(FRSDefaultNotificationTableViewCell *)cell userIDs:(NSArray *)userIDs {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeFollow];
    cell.count = userIDs.count;
    cell.followButton.alpha = 1;
    [self configureUserAttributes:cell userID:[userIDs objectAtIndex:0]];
    
}

-(void)configureLikeCell:(FRSDefaultNotificationTableViewCell *)cell userIDs:(NSArray *)userIDs galleryID:(NSString *)galleryID {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeLike];
    cell.count = userIDs.count;
    [self configureUserAttributes:cell userID:[userIDs objectAtIndex:0]];
}

-(void)configureRepostCell:(FRSDefaultNotificationTableViewCell *)cell userIDs:(NSArray *)userIDs galleryID:(NSString *)galleryID {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeRepost];
    cell.count = userIDs.count;
    [self configureUserAttributes:cell userID:[userIDs objectAtIndex:0]];
}

-(void)configureCommentCell:(FRSDefaultNotificationTableViewCell *)cell userIDs:(NSArray *)userIDs galleryID:(NSString *)galleryID {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeComment];
    cell.count = userIDs.count;
    [self configureUserAttributes:cell userID:[userIDs objectAtIndex:0]];
}


-(void)configureUserAttributes:(FRSDefaultNotificationTableViewCell *)cell userID:(NSString *)userID {
    
//    cell.titleLabel.text = @"\n";
    cell.annotationView.alpha = 1;
    cell.annotationLabel.alpha = 1;

    [[FRSAPIClient sharedClient] getUserWithUID:userID completion:^(id responseObject, NSError *error) {
        
        if (![[responseObject objectForKey:@"full_name"] isEqualToString:@""]) {
            cell.titleLabel.text = [responseObject objectForKey:@"full_name"];
        } else {
            cell.titleLabel.text = [responseObject objectForKey:@"username"];
        }
        
        if([responseObject objectForKey:@"avatar"] != [NSNull null]){
            NSURL *avatarURL = [NSURL URLWithString:[responseObject objectForKey:@"avatar"]];
            [cell.image hnk_setImageFromURL:avatarURL];
        }
        
        if ([[responseObject objectForKey:@"following"] boolValue]) {
            [cell.followButton setImage:[UIImage imageNamed:@"account-check"] forState:UIControlStateNormal];
            cell.followButton.tintColor = [UIColor frescoOrangeColor];
        } else {
            [cell.followButton setImage:[UIImage imageNamed:@"account-add"] forState:UIControlStateNormal];
            cell.followButton.tintColor = [UIColor blackColor];
        }

        self.loadedNotificationCount++;

        [cell updateLabelsForCount];
    }];
}


#pragma mark - Payment

-(void)configurePurchasedContentCell:(FRSDefaultNotificationTableViewCell *)cell outletID:(NSString *)outletID postID:(NSString *)postID hasPaymentInfo:(BOOL)paymentInfo {
    
    cell.titleLabel.text = @"Your photo was purchased!";
    cell.bodyLabel.numberOfLines = 3;
//    cell.bodyLabel.text = @"\n\n";

    [[FRSAPIClient sharedClient] getOutletWithID:outletID completion:^(id responseObject, NSError *error) {
        
        NSString *outletName = @"(null)";
        NSString *price = @"(null)";
        NSString *paymentMethod = @"(null)";
        
        if (paymentInfo) {
            cell.bodyLabel.text = [NSString stringWithFormat:@"%@ purchased your photo! We've sent %@ to your %@.", outletName, price, paymentMethod];
        } else {
            cell.bodyLabel.text = [NSString stringWithFormat:@"%@ purchased your photo! Tap to add a card and we’ll send you %@!", outletName, price];
        }
        
        
        
        [[FRSAPIClient sharedClient] getPostWithID:postID completion:^(id responseObject, NSError *error) {
            
            if([responseObject objectForKey:@"image"] != [NSNull null]){
                
                NSURL *avatarURL = [NSURL URLWithString:[responseObject objectForKey:@"image"]];
                [cell.image hnk_setImageFromURL:avatarURL];
            }
            
            self.loadedNotificationCount++;
            
        }];
    }];

}

-(void)configurePaymentExpiringCell:(FRSDefaultNotificationTableViewCell *)cell {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    [cell configureDefaultCell];
    
    NSString *total = @"(null)";
    
    cell.titleLabel.text = [NSString stringWithFormat: @"You have %@ expiring soon", total];
    cell.bodyLabel.text = @"Add a payment method to get paid";
    
    self.loadedNotificationCount++;
}

-(void)configurePaymentSentCell:(FRSDefaultNotificationTableViewCell *)cell {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"(null) sent to (null).";
    
    self.loadedNotificationCount++;
}

-(void)configurePaymentDeclinedCell:(FRSDefaultNotificationTableViewCell *)cell {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Our payment to (null) was declined";
    cell.bodyLabel.text = @"Please reenter your payment information";
    
    self.loadedNotificationCount++;
}

-(void)configureTaxInfoRequiredCell:(FRSDefaultNotificationTableViewCell *)cell {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Tax information needed";
    cell.bodyLabel.text = @"You’ve made almost $2,000 on Fresco! Please add your tax info soon to continue receiving payments.";
    
    self.loadedNotificationCount++;
}

-(void)configureTaxInfoProcessedCell:(FRSDefaultNotificationTableViewCell *)cell processed:(BOOL)processed{
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    if (processed) {
        cell.titleLabel.text = @"Your tax info was accepted!";
    } else {
        [self configureTaxInfoDeclinedCell:cell];
    }
    
    self.loadedNotificationCount++;
}

-(void)configureTaxInfoDeclinedCell:(FRSDefaultNotificationTableViewCell *)cell {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Your tax information was declined";
    cell.bodyLabel.text = @"Please reenter your tax information";
    
    self.loadedNotificationCount++;
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

-(void)returnToProfile {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}




@end
