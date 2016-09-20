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


@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource, FRSExternalNavigationDelegate, FRSAlertViewDelegate, FRSDefaultNotificationCellDelegate>

@property (strong, nonatomic) NSDictionary *payload;
@property (strong, nonatomic) NSArray *feed;
@property BOOL isSegueingToGallery;
@property BOOL isSegueingToStory;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *spinner;

@end

@implementation FRSUserNotificationViewController

NSString * const TEXT_ID       = @"textNotificationCell";
NSString * const DEFAULT_ID    = @"notificationCell";
NSString * const ASSIGNMENT_ID = @"assignmentNotificationCell";

//-(instancetype)init {
//    self = [super init];
//    
//    if (self) {
//        self.tabBarController.tabBarItem.title = @"";
//        
//        self.payload = [[NSDictionary alloc] init];
//        
//        NSArray *post_ids    = @[@"LJx3jeQg1kpN", @"5xQ0WoLw0lX9", @"EL2Z3meP39jR", @"6DrY8KYM1KBP", @"Qz7J07vY8dDZ"];
//        NSArray *gallery_ids = @[@"YQVr1ElM05qP", @"dYOJ8vjz8ML4", @"YZb485DD3xoV", @"gBbY3oPB8PM6"];
//        NSString *gallery_id = @"arYd0y5Q0Dp5";
//        NSString *story_id   = @"7mr93zRx3BlY";
//        NSString *empty = @"";
//        NSArray *user_ids = @[@"2vRW0Na8oEgQ", @"ewOo1Pr8KvlN", @"Ym4x8rK0Jjpd"];
//
//        NSString *assignment_id = @"xLJE0QzW1G5B";
//
//        NSString *outlet_id = @"7ewm8YP3GL5x";
//        
//        NSString *body = @"BREAKING: Bernie Sanders wins South Carolina Democratic primary, with an unheard of 130% of the popular vote";
//
//
//        self.payload = @{
//                         
//                         //photoOfDayNotification : post_ids,
//                         todayInNewsNotification : gallery_ids,
//                         userNewsGalleryNotification : gallery_id,
//                         userNewsStoryNotification : story_id,
//                         userNewsCustomNotification : body,
//                         
//                         followedNotification : user_ids,
//                         likedNotification : @{@"user_ids" : user_ids, @"gallery_id": gallery_id},
//                         repostedNotification : @{@"user_ids" : user_ids, @"gallery_id": gallery_id},
//                         commentedNotification : @{@"user_ids" : user_ids, @"gallery_id": gallery_id},
//                         //mentionCommentNotification : @[], //cc: api
//                         //mentionGalleryNotification : @[], //cc: api
//                         
//                         newAssignmentNotification : assignment_id,
//                         
//                         purchasedContentNotification : @{@"outlet_id" : outlet_id, @"post_ids" : post_ids, @"has_card_": @TRUE},
//                         paymentExpiringNotification : empty,
//                         paymentSentNotification: empty,
//                         paymentDeclinedNotification : empty,
//                         taxInfoRequiredNotification : empty,
//                         taxInfoProcessedNotification : @NO,
//                         taxInfoDeclinedNotification : @YES,
//                         taxInfoProcessedNotification : @YES,
//                         
//                         };
//    }
//    
//    return self;
//}


-(void)viewDidLoad {
    [super viewDidLoad];
    [self getNotifications];
    [self configureUI];
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

-(void)getNotifications {
    [[FRSAPIClient sharedClient] getNotificationsWithCompletion:^(id responseObject, NSError *error) {
        self.feed = [responseObject objectForKey:@"feed"];
        [self configureTableView];
        [self registerNibs];
        [self.spinner stopLoading];
    }];
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

-(void)configureSpinner {
    self.spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.spinner.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.spinner.tintColor = [UIColor frescoOrangeColor];
    [self.spinner setPullProgress:90];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
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
    
    if (self.feed.count == 0) {
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
    return self.feed.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



/* HIDE ALL SEEN NOTIFICATIONS */

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    NSString *type = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];
//    BOOL seen      = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"seen"] boolValue];
//    BOOL hasCard   = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"has_card_"] boolValue];
//    
//    BOOL shouldHide; //Hides the cell from view by setting its height to zero
//    
//    if ([type isEqualToString:newAssignmentNotification] && seen) {
//        shouldHide = YES;
//    } else if ([type isEqualToString:purchasedContentNotification] && seen && !hasCard) {
//        shouldHide = YES;
//    } else if ([type isEqualToString:paymentExpiringNotification] && seen) {
//        shouldHide = YES;
//    } else if ([type isEqualToString:paymentDeclinedNotification] && seen) {
//        shouldHide = YES;
//    } else if ([type isEqualToString:taxInfoRequiredNotification] && seen) {
//        shouldHide = YES;
//    } else if ([type isEqualToString:taxInfoDeclinedNotification] && seen) {
//        shouldHide = YES;
//    } else {
//        shouldHide = NO;
//    }
//
//    if (shouldHide) {
//        return 0;
//    } else {
//        UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
//
//        if ([[cell class] isSubclassOfClass:[FRSDefaultNotificationTableViewCell class]]) {
//            FRSDefaultNotificationTableViewCell *defaultCell = (FRSDefaultNotificationTableViewCell *)cell;
//            return [defaultCell heightForCell];
//        }
//        
//        if ([[cell class] isSubclassOfClass:[FRSAssignmentNotificationTableViewCell class]]) {
//            FRSAssignmentNotificationTableViewCell *assignmentCell = (FRSAssignmentNotificationTableViewCell *)cell;
//            return [assignmentCell heightForCell];
//        }
//        
//        if ([[cell class] isSubclassOfClass:[FRSTextNotificationTableViewCell class]]) {
//            FRSTextNotificationTableViewCell *textCell = (FRSTextNotificationTableViewCell *)cell;
//            return [textCell heightForCell];
//        }
//    }
//    
//    return 0; //Won't ever get called
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FRSAssignmentNotificationTableViewCell *assignmentCell = [tableView dequeueReusableCellWithIdentifier:ASSIGNMENT_ID];
    assignmentCell.delegate = self;
    
    FRSTextNotificationTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:TEXT_ID];

    NSString *currentKey = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];
    NSLog(@"%@", [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"]);

    /* NEWS */
    if ([currentKey isEqualToString:photoOfDayNotification]) {
        NSLog(@"PHOTOS OF THE DAY");
    } else if ([currentKey isEqualToString:todayInNewsNotification]) {
        NSLog(@"TODAY IN NEWS");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTodayInNews:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsGalleryNotification]) {
        NSLog(@"USER NEWS GALLERY");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureGalleryCell:defaultCell galleryID:[self.payload objectForKey:userNewsGalleryNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsStoryNotification]) {
        NSLog(@"USER NEWS STORY");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureStoryCell:defaultCell storyID:[self.payload objectForKey:userNewsStoryNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsCustomNotification]) {
        NSLog(@"USER NEWS CUSTOM");
        [self configureTextCell:textCell text:[self.payload objectForKey:userNewsCustomNotification]];
        return textCell;
        
    /* SOCIAL */
    } else if ([currentKey isEqualToString:followedNotification]) {
        NSLog(@"FOLLOWED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureFollowCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        defaultCell.delegate = self;
        defaultCell.indexPath = indexPath;
        return defaultCell;
        
    } else if ([currentKey isEqualToString:likedNotification]) {
        NSLog(@"LIKED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureLikeCell:defaultCell userIDs:[[self.payload objectForKey:likedNotification] objectForKey:@"user_ids"] galleryID:[[self.payload objectForKey:likedNotification] objectForKey:@"gallery_id"]];
        return defaultCell;

    } else if ([currentKey isEqualToString:repostedNotification]) {
        NSLog(@"REPOSTED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureRepostCell:defaultCell userIDs:[[self.payload objectForKey:repostedNotification] objectForKey:@"user_ids"] galleryID:[[self.payload objectForKey:repostedNotification] objectForKey:@"gallery_id"]];
        return defaultCell;

    } else if ([currentKey isEqualToString:commentedNotification]) {
        NSLog(@"COMMENTED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureCommentCell:defaultCell userIDs:[[self.payload objectForKey:commentedNotification] objectForKey:@"user_ids"] galleryID:[[self.payload objectForKey:commentedNotification] objectForKey:@"gallery_id"]];
        return defaultCell;

    }/* else if ([currentKey isEqualToString:mentionCommentNotification]) {
        NSLog(@"MENTION COMMENT");
    } else if ([currentKey isEqualToString:mentionGalleryNotification]) {
        NSLog(@"MENTION GALLERY");
    }*/
    
    /* ASSIGNMENT */
    else if ([currentKey isEqualToString:newAssignmentNotification]) {
        [self configureAssignmentCell:assignmentCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        assignmentCell.delegate = self;
        if ([self seen:indexPath]) {
            assignmentCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return assignmentCell;
    }
    
    /* PAYMENT */
    else if ([currentKey isEqualToString:purchasedContentNotification]) {
        NSLog(@"PURCHASED CONTENT");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configurePurchasedContentCell:defaultCell outletID:[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"outlet_id"] postID:[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"post_id"] hasPaymentInfo:[[self.payload objectForKey:purchasedContentNotification] objectForKey:@"has_card_"]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentExpiringNotification]) {
        NSLog(@"PAYMENT EXPIRING");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configurePaymentExpiringCell:defaultCell];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentSentNotification]) {
        NSLog(@"PAYMENT SENT");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configurePaymentSentCell:defaultCell];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentDeclinedNotification]) {
        NSLog(@"PAYMENT DECLINED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configurePaymentDeclinedCell:defaultCell];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:taxInfoRequiredNotification]) {
        NSLog(@"TAX INFO REQUIRED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTaxInfoRequiredCell:defaultCell];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:taxInfoProcessedNotification]) {
        NSLog(@"TAX INFO PROCESSING");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTaxInfoProcessedCell:defaultCell processed:[self.payload objectForKey:taxInfoProcessedNotification]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:taxInfoDeclinedNotification]) {
        NSLog(@"TAX INFO DECLINED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTaxInfoDeclinedCell:defaultCell];
        return defaultCell;
        
    } else {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        return defaultCell;
    }

    FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
    return defaultCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self shouldHideCellAtIndexPath:indexPath]) {
        
        //Delete from API   cc: mike
    }
    
    if ([self hasSeenCellAtIndexPath:indexPath]) {
        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    }
}

-(BOOL)shouldHideCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];
    BOOL seen      = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"seen"] boolValue];
    BOOL hasCard   = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"has_card_"] boolValue];
    
    BOOL shouldHide; //Hides the cell from view by setting its height to zero
    
    if ([type isEqualToString:newAssignmentNotification] && seen) {
        shouldHide = YES;
    } else if ([type isEqualToString:purchasedContentNotification] && seen && !hasCard) {
        shouldHide = YES;
    } else if ([type isEqualToString:paymentExpiringNotification] && seen) {
        shouldHide = YES;
    } else if ([type isEqualToString:paymentDeclinedNotification] && seen) {
        shouldHide = YES;
    } else if ([type isEqualToString:taxInfoRequiredNotification] && seen) {
        shouldHide = YES;
    } else if ([type isEqualToString:taxInfoDeclinedNotification] && seen) {
        shouldHide = YES;
    } else {
        shouldHide = NO;
    }
    
    return shouldHide;
}

-(BOOL)hasSeenCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];
    BOOL hasSeen   = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"seen"] boolValue];
    
    if ([type isEqualToString:newAssignmentNotification] && hasSeen) {
        hasSeen = YES;
    } else if ([type isEqualToString:purchasedContentNotification] && hasSeen) {
        hasSeen = YES;
    } else if ([type isEqualToString:paymentExpiringNotification] && hasSeen) {
        hasSeen = YES;
    } else if ([type isEqualToString:paymentDeclinedNotification] && hasSeen) {
        hasSeen = YES;
    } else if ([type isEqualToString:taxInfoRequiredNotification] && hasSeen) {
        hasSeen = YES;
    } else if ([type isEqualToString:taxInfoDeclinedNotification] && hasSeen) {
        hasSeen = YES;
    } else {
        hasSeen = NO;
    }
    
    return hasSeen;
}

-(BOOL)seen:(NSIndexPath *)indexPath {
    
    return [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"seen"] boolValue];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *currentKey = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];
    NSLog(@"%@", [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"]);
    
    /* NEWS */
    if ([currentKey isEqualToString:photoOfDayNotification]) {

    } else if ([currentKey isEqualToString:todayInNewsNotification]) {
        
        NSArray *galleryIDs = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_ids"];
        
        if (galleryIDs) {
            [self segueToTodayInNews:galleryIDs];
        }
        
    } else if ([currentKey isEqualToString:userNewsGalleryNotification]) {
        [self segueToGallery:[self.feed objectAtIndex:indexPath.row]];
        
    } else if ([currentKey isEqualToString:userNewsStoryNotification]) {
        [self segueToStory:[self.payload objectForKey:userNewsStoryNotification]];

    } else if ([currentKey isEqualToString:userNewsCustomNotification]) {
        // Do nothing (for now)
        
    /* SOCIAL */
    } else if ([currentKey isEqualToString:followedNotification]) {
        
        NSString *userID = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"user_id"];
        [self segueToUser:userID];
        
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
        //check for global
        NSLog(@"%@", [self.feed objectAtIndex:indexPath.row]);
        NSString *assignmentID = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"assignment_id"];
        [self segueToAssignmentWithID:assignmentID];
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
-(void)configureTodayInNews:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary*)dictionary {
    [cell configureDefaultCell];
    
    cell.titleLabel.text = dictionary[@"title"];
    cell.bodyLabel.text = dictionary[@"body"];
    
//    cell.titleLabel.text = @"Today in News";
//    cell.bodyLabel.numberOfLines = 3;
//    cell.bodyLabel.text = @"\n\n\n";
    
//    [[FRSAPIClient sharedClient] getGalleryWithUID:[galleryIDs objectAtIndex:0] completion:^(id responseObject, NSError *error) {
//        
//        NSDictionary *dict = @{@"body": [responseObject objectForKey:@"caption"], @"url" : [[[responseObject objectForKey:@"posts"] objectAtIndex:1] objectForKey:@"image"]};
//        
//        [self.loadedNotifications addObject:dict];
//        cell.bodyLabel.text = [responseObject objectForKey:@"caption"];
//        NSURL *galleryURL = [NSURL URLWithString:[[[responseObject objectForKey:@"posts"] objectAtIndex:1] objectForKey:@"image"]];
//        [cell.image hnk_setImageFromURL:galleryURL];
//    }];
}


-(void)configureGalleryCell:(FRSDefaultNotificationTableViewCell *)cell galleryID:(NSString *)galleryID {
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Featured Gallery";
    cell.bodyLabel.numberOfLines = 3;
    
    [[FRSAPIClient sharedClient] getGalleryWithUID:galleryID completion:^(id responseObject, NSError *error) {
       
        cell.bodyLabel.text = [responseObject objectForKey:@"caption"];
        
        NSURL *galleryURL = [NSURL URLWithString:[[[responseObject objectForKey:@"posts"] objectAtIndex:1] objectForKey:@"image"]];
        [cell.image hnk_setImageFromURL:galleryURL];
    }];
}


-(void)configureStoryCell:(FRSDefaultNotificationTableViewCell *)cell storyID:(NSString *)storyID {
    [cell configureDefaultCell];
    
    [[FRSAPIClient sharedClient] getStoryWithUID:storyID completion:^(id responseObject, NSError *error) {
        
        cell.titleLabel.text = [NSString stringWithFormat:@"Featured Story: %@", [responseObject objectForKey:@"title"]];
        cell.bodyLabel.text = [responseObject objectForKey:@"caption"];
        cell.bodyLabel.numberOfLines = 3;
        cell.titleLabel.numberOfLines = 2;
        
        if([responseObject objectForKey:@"thumbnails"] != [NSNull null]){
            NSURL *avatarURL = [NSURL URLWithString:[[[responseObject objectForKey:@"thumbnails"] objectAtIndex:0] objectForKey:@"image"]];
            [cell.image hnk_setImageFromURL:avatarURL];
        }
    }];
}

-(void)configureTextCell:(FRSTextNotificationTableViewCell *)textCell text:(NSString *)text {
    textCell.label.numberOfLines = 0;
    textCell.label.text = text;
}


#pragma mark - Assignments
-(void)configureAssignmentCell:(FRSAssignmentNotificationTableViewCell *)assignmentCell dictionary:(NSDictionary *)dictionary {
    
    assignmentCell.titleLabel.numberOfLines = 0;
    assignmentCell.bodyLabel.numberOfLines  = 3;
    assignmentCell.actionButton.tintColor = [UIColor blackColor];
    
    assignmentCell.titleLabel.text = [dictionary objectForKey:@"title"];
    assignmentCell.bodyLabel.text = [dictionary objectForKey:@"body"];
//    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
//        
//        assignmentCell.titleLabel.text = [responseObject objectForKey:@"title"];
//        assignmentCell.bodyLabel.text = [responseObject objectForKey:@"caption"];
//        
//        self.loadedNotificationCount++;
//    }];
}


#pragma mark - Social

-(void)configureFollowCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeFollow];
    
    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    
    NSArray *userIDs = [[dictionary objectForKey:@"meta"] objectForKey:@"user_ids"];
    
    cell.count = userIDs.count;
    cell.followButton.alpha = 1;
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


        [cell updateLabelsForCount];
    }];
}


#pragma mark - Payment

-(void)configurePurchasedContentCell:(FRSDefaultNotificationTableViewCell *)cell outletID:(NSString *)outletID postID:(NSString *)postID hasPaymentInfo:(BOOL)paymentInfo {
    
    cell.titleLabel.text = @"Your photo was purchased!";
    cell.bodyLabel.numberOfLines = 3;

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
}

-(void)configurePaymentSentCell:(FRSDefaultNotificationTableViewCell *)cell {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"(null) sent to (null).";
}

-(void)configurePaymentDeclinedCell:(FRSDefaultNotificationTableViewCell *)cell {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Our payment to (null) was declined";
    cell.bodyLabel.text = @"Please reenter your payment information";
}

-(void)configureTaxInfoRequiredCell:(FRSDefaultNotificationTableViewCell *)cell {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Tax information needed";
    cell.bodyLabel.text = @"You’ve made almost $2,000 on Fresco! Please add your tax info soon to continue receiving payments.";
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
}

-(void)configureTaxInfoDeclinedCell:(FRSDefaultNotificationTableViewCell *)cell {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = @"Your tax information was declined";
    cell.bodyLabel.text = @"Please reenter your tax information";
}


#pragma mark - Actions

-(void)popViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)returnToProfile {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - FRSDelegates


/* Gets called when the user taps on the right aligned button on default notification cells */
-(void)customButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notification = [self.feed objectAtIndex:indexPath.row];
    
    if ([[notification objectForKey:@"type"] isEqualToString:followedNotification]) {
        
        [self followUserFromID:[notification objectForKey:@"user_id"]];
        
    }
    NSLog(@"%@", [self.feed objectAtIndex:indexPath.row]);
    
}

-(void)followUserFromID:(NSString *)userID {

    [[FRSAPIClient sharedClient] getUserWithUID:userID completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        FRSUser *currentUser = [FRSUser nonSavedUserWithProperties:responseObject context:[delegate managedObjectContext]];
        
        if ([[responseObject valueForKey:@"following"] boolValue]) {
            [self unfollowUser:currentUser];
        } else {
            [self followUser:currentUser];
        }
    }];
}



-(void)followUser:(FRSUser *)user {
    [[FRSAPIClient sharedClient] followUser:user completion:^(id responseObject, NSError *error) {
        
        if (error) {
            
            return;
        }
    }];
}

-(void)unfollowUser:(FRSUser *)user {
    [[FRSAPIClient sharedClient] unfollowUser:user completion:^(id responseObject, NSError *error) {
        
        if (error) {
            
            return;
        }
    }];
}




/* Gets called when the user taps on the right aligned button on assignment notification cells */
-(void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    FRSAlertView *alert = [[FRSAlertView alloc] init];
    alert.delegate = self;
    [alert navigateToAssignmentWithLatitude:latitude longitude:longitude];
}


@end
