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

#import "FRSAwkwardView.h"
#import "FRSAssignment.h"
#import "FRSAlertView.h"

#import <Haneke/Haneke.h>



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
    /*if (self.tabBarController) {
        [(FRSTabBarController *)self.tabBarController updateUserIcon];
    } else {
        FRSTabBarController *tabBarController = (FRSTabBarController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        [tabBarController updateUserIcon];
    }*/
}

-(void)getNotifications {
    [[FRSAPIClient sharedClient] getNotificationsWithCompletion:^(id responseObject, NSError *error) {
        self.feed = [responseObject objectForKey:@"feed"];
        
        [self configureTableView];
        [self registerNibs];
        [self.spinner stopLoading];
        
        NSMutableArray *toMarkAsRead = [[NSMutableArray alloc] init];
        
        for (NSDictionary *notif in self.feed) {
            [toMarkAsRead addObject:notif[@"id"]];
        }
        
        [self markAllAsRead:toMarkAsRead];
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

-(void)loadMore {
    if (!loadingMoreNotifications && !reachedBottom) {
        loadingMoreNotifications = TRUE;
        NSString *lastNotifID = [[self.feed lastObject] objectForKey:@"id"];
        
        [[FRSAPIClient sharedClient] getNotificationsWithLast:lastNotifID completion:^(id responseObject, NSError *error) {
            if (!error) {
                NSMutableArray *feed = [self.feed mutableCopy];
                NSArray *notifications = responseObject[@"feed"];
                
                if (!notifications || notifications.count == 0) {
                    reachedBottom = TRUE;
                }
                
                [feed addObjectsFromArray:notifications];
                self.feed = feed;
            }
            
            [self.tableView reloadData];
            loadingMoreNotifications = FALSE;
        }];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row >= self.feed.count-2) {
        [self loadMore];
    }
    
    NSString *currentKey = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];

    /* NEWS */
    if ([currentKey isEqualToString:photoOfDayNotification]) {
        NSLog(@"PHOTOS OF THE DAY");
        
    } else if ([currentKey isEqualToString:todayInNewsNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

        [self configureTodayInNews:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
        
        
    } else if ([currentKey isEqualToString:userNewsGalleryNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

        [self configureGalleryCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
        
        
    } else if ([currentKey isEqualToString:userNewsStoryNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

        [self configureStoryCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:userNewsCustomNotification]) {
        FRSTextNotificationTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:TEXT_ID];

        [self configureTextCell:textCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        
        if ([self seen:indexPath]) {
            textCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return textCell;
        
        
        
    /* SOCIAL */
    } else if ([currentKey isEqualToString:followedNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

        [self configureFollowCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        defaultCell.delegate = self;
        defaultCell.indexPath = indexPath;
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
        
        
    } else if ([currentKey isEqualToString:likedNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

        [self configureLikeCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:repostedNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

        [self configureRepostCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
    }
    else if ([currentKey isEqualToString:galleryApprovedNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        
        [self configureGalleryCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        
        return defaultCell;

    } else if ([currentKey isEqualToString:commentedNotification] || [currentKey isEqualToString:mentionCommentNotification] || [currentKey isEqualToString:mentionGalleryNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        NSLog(@"COMMENTED");
        [self configureCommentCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;

    }
    /* ASSIGNMENT */
    else if ([currentKey isEqualToString:newAssignmentNotification]) {
        FRSAssignmentNotificationTableViewCell *assignmentCell = [tableView dequeueReusableCellWithIdentifier:ASSIGNMENT_ID];
        assignmentCell.delegate = self;

        [self configureAssignmentCell:assignmentCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        assignmentCell.delegate = self;
        if ([self seen:indexPath]) {
            assignmentCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }

        return assignmentCell;
    }
    
    /* PAYMENT */
    else if ([currentKey isEqualToString:purchasedContentNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        NSLog(@"PURCHASED CONTENT");
        [self configureGalleryCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentExpiringNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        NSLog(@"PAYMENT EXPIRING");
        [self configurePaymentExpiringCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentSentNotification]) {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        NSLog(@"PAYMENT SENT");
        [self configurePaymentSentCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:paymentDeclinedNotification]) {
        NSLog(@"PAYMENT DECLINED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configurePaymentDeclinedCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:taxInfoRequiredNotification]) {
        NSLog(@"TAX INFO REQUIRED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTaxInfoRequiredCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:taxInfoProcessedNotification]) {
        NSLog(@"TAX INFO PROCESSING");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTaxInfoProcessedCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else if ([currentKey isEqualToString:taxInfoDeclinedNotification]) {
        NSLog(@"TAX INFO DECLINED");
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        [self configureTaxInfoDeclinedCell:defaultCell dictionary:[self.feed objectAtIndex:indexPath.row]];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
        
    } else {
        FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];
        if ([self seen:indexPath]) {
            defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        return defaultCell;
    }

    FRSDefaultNotificationTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_ID];

    if ([self seen:indexPath]) {
        defaultCell.backgroundColor = [UIColor frescoBackgroundColorDark];
    }
    return defaultCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self shouldHideCellAtIndexPath:indexPath]) {
        
        //Delete from API   cc: mike
    }
    
    if ([self hasSeenCellAtIndexPath:indexPath]) {
        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    }
    else {
        cell.backgroundColor = [UIColor frescoBackgroundColorLight];
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
    BOOL hasSeen   = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"seen"] boolValue];
    
    return hasSeen;
}

-(BOOL)seen:(NSIndexPath *)indexPath {
    
    return [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"seen"] boolValue];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *currentKey = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"];
    NSLog(@"%@", [[self.feed objectAtIndex:indexPath.row] objectForKey:@"type"]);
    
    NSString *notificationID = [[self.feed objectAtIndex:indexPath.row] objectForKey:@"id"];
    
    if (notificationID && ![notificationID isEqual:[NSNull null]]) {
        [self markAsRead:notificationID];
    }
    
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
        
        NSString *userID = [[[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"user_ids"] firstObject];
        [self segueToUser:userID];
        
    } else if ([currentKey isEqualToString:likedNotification]) {
        NSString *gallery = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];

        [self segueToGallery:gallery];
        
    } else if ([currentKey isEqualToString:repostedNotification]) {
        NSString *gallery = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];
        
        [self segueToGallery:gallery];
    } else if ([currentKey isEqualToString:commentedNotification] || [currentKey isEqualToString:mentionCommentNotification]) {
        NSString *gallery = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];
        
        [self segueToGallery:gallery];
    } else if ([currentKey isEqualToString:mentionCommentNotification]) {
        NSLog(@"MENTION COMMENT");
        NSString *gallery = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];
        
        NSString *comment = [[[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"comment_ids"] firstObject];
        
        [self segueToComment:comment inGallery:gallery];
      }
    else if ([currentKey isEqualToString:mentionGalleryNotification]) {
      NSLog(@"MENTION GALLERY");
        NSString *gallery = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];
        
        NSString *comment = [[[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"comment_ids"] firstObject];
        
        [self segueToComment:comment inGallery:gallery];
      }
    else if ([currentKey isEqualToString:galleryApprovedNotification]) {
        NSString *gallery = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];

        NSLog(@"APPROVED: %@", gallery);
        [self segueToGallery:gallery];
    }
    
    /* ASSIGNMENT */
    else if ([currentKey isEqualToString:newAssignmentNotification]) {
        //check for global
        NSLog(@"%@", [self.feed objectAtIndex:indexPath.row]);
        NSString *assignmentID = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"assignment_id"];
        [self segueToAssignmentWithID:assignmentID];
    }
    
    /* PAYMENT */
    else if ([currentKey isEqualToString:purchasedContentNotification]) {
        NSString *postID = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"post_id"];
        NSString *galleryID = [[[self.feed objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"gallery_id"];
        [self segueToPost:postID inGallery:galleryID];
        
    } else if ([currentKey isEqualToString:paymentExpiringNotification]) {
        [self segueToDebitCard];
        
    } else if ([currentKey isEqualToString:paymentSentNotification]) {
        
    } else if ([currentKey isEqualToString:paymentDeclinedNotification]) {
        [self segueToDebitCard];

    } else if ([currentKey isEqualToString:taxInfoRequiredNotification]) {
        [self segueToTaxInfo];
        
    } else if ([currentKey isEqualToString:taxInfoProcessedNotification]) {
        // do nothing
        [self segueToTaxInfo];
        
    } else if ([currentKey isEqualToString:taxInfoDeclinedNotification]) {
        [self segueToTaxInfo];
    } else {

    
    }
}

-(void)segueToPost:(NSString *)postID inGallery:(NSString *)gallery {
    [[FRSAPIClient sharedClient] getGalleryWithUID:gallery completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[appDelegate managedObjectContext]];
        
        [galleryToSave configureWithDictionary:responseObject context:[appDelegate managedObjectContext]];
        
        FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:galleryToSave];
        vc.shouldHaveBackButton = YES;
        [vc focusOnPost:postID];
        
        if (!self.isSegueingToGallery) {
            self.isSegueingToGallery = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        [self hideTabBarAnimated:YES];
    }];

}
-(void)segueToComment:(NSString *)commentID inGallery:(NSString *)gallery {
    
}
#pragma mark - Cell Configuration

#pragma mark - News
-(void)configureTodayInNews:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary*)dictionary {
    [cell configureDefaultCell];
    
    cell.titleLabel.text = dictionary[@"title"];
    cell.bodyLabel.text = dictionary[@"body"];
    
    if ([self hasImage:dictionary]) {
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
}


-(void)configureGalleryCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell configureDefaultCell];
    
    cell.titleLabel.text = dictionary[@"title"];
    cell.bodyLabel.text = dictionary[@"body"];

    if ([self hasImage:dictionary]) {
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
}


-(void)configureStoryCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell configureDefaultCell];
    
    NSString *storyTitle = @"(null)"; //pass in from api
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Featured Story:%@", storyTitle];
    cell.bodyLabel.text = dictionary[@"body"];

    if ([self hasImage:dictionary]) {
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
}

-(void)configureTextCell:(FRSTextNotificationTableViewCell *)textCell dictionary:(NSDictionary *)dictionary {
    
    textCell.label.numberOfLines = 0;
    textCell.textLabel.text = [dictionary objectForKey:@"body"];

}

-(void)markAllAsRead:(NSArray *)notificationIDS {
    NSDictionary *params = @{@"notification_ids":notificationIDS};
    [[FRSAPIClient sharedClient] post:@"user/notifications/see" withParameters:params completion:^(id responseObject, NSError *error) {
        BOOL success = FALSE;
        
        if (!error && responseObject) {
            success = TRUE;
        }
        
        NSLog(@"MARK AS READ SUCCESS: %d", success);
    }];
}

-(void)markAsRead:(NSString *)notificationID {
    NSDictionary *params = @{@"notification_ids":@[notificationID]};
    [[FRSAPIClient sharedClient] post:@"user/notifications/see" withParameters:params completion:^(id responseObject, NSError *error) {
        BOOL success = FALSE;
        
        if (!error && responseObject) {
            success = TRUE;
        }
        
        NSLog(@"MARK AS READ SUCCESS: %d", success);
    }];
}

#pragma mark - Assignments
-(void)configureAssignmentCell:(FRSAssignmentNotificationTableViewCell *)assignmentCell dictionary:(NSDictionary *)dictionary {
    assignmentCell.titleLabel.numberOfLines = 0;
    assignmentCell.bodyLabel.numberOfLines  = 3;
    assignmentCell.actionButton.tintColor = [UIColor blackColor];
    assignmentCell.titleLabel.text = [dictionary objectForKey:@"title"];
    assignmentCell.bodyLabel.text = [dictionary objectForKey:@"body"];
}


#pragma mark - Social

-(void)configureFollowCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeFollow];
    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    NSArray *userIDs = [[dictionary objectForKey:@"meta"] objectForKey:@"user_ids"];
    cell.count = userIDs.count;
    cell.followButton.alpha = 1;
    
    if ([self hasImage:dictionary]) {
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
}

-(void)configureLikeCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeLike];
    //cell.count = userIDs.count; //pull from api
    //user image
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
    NSArray *userIDs = [[dictionary objectForKey:@"meta"] objectForKey:@"user_ids"];
    cell.count = userIDs.count;
    
    if (userIDs.count > 1) {
        cell.followButton.alpha = 1;
    }
    else {
        cell.followButton.alpha = 0;
    }
    
    if (userIDs.count > 1) {
        cell.followButton.alpha = 1;
    }
    else {
        cell.followButton.alpha = 0;
    }

    if ([self hasImage:dictionary]) {
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
}

-(void)configureRepostCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    
    if ([self hasImage:dictionary]) {
        [cell configureImageCell];
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
    else {
        [cell configureDefaultCell];
    }
    
    NSArray *userIDs = [[dictionary objectForKey:@"meta"] objectForKey:@"user_ids"];
    cell.count = userIDs.count;
    
    if (userIDs.count > 1) {
        cell.followButton.alpha = 1;
    }
    else {
        cell.followButton.alpha = 0;
    }
    [cell configureDefaultCellWithAttributesForNotification:FRSNotificationTypeRepost];
//    cell.count = userIDs.count;
//    [self configureUserAttributes:cell userID:[userIDs objectAtIndex:0]];
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
}

-(void)configureCommentCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
//    cell.count = userIDs.count;
//    [self configureUserAttributes:cell userID:[userIDs objectAtIndex:0]];
    
    if ([self hasImage:dictionary]) {
        [cell configureDefaultCell];
        [cell configureImageCell];
        [cell.image hnk_setImageFromURL:[NSURL URLWithString:dictionary[@"meta"][@"image"]]];
    }
    else {
        [cell configureDefaultCell];
    }
    
    
    NSArray *userIDs = [[dictionary objectForKey:@"meta"] objectForKey:@"user_ids"];
    cell.count = userIDs.count;
    
    if (userIDs.count > 1) {
        cell.followButton.alpha = 1;
    }
    else {
        cell.followButton.alpha = 0;
    }

    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
}

-(BOOL)hasImage:(NSDictionary *)dictionary {
    if (dictionary[@"meta"][@"image"] != Nil && ![dictionary[@"meta"][@"image"] isEqual:[NSNull null]] && [[dictionary[@"meta"][@"image"] class] isSubclassOfClass:[NSString class]]) {
        return TRUE;
    }
    
    return FALSE;
}

#pragma mark - Payment

-(void)configurePurchasedContentCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
}

-(void)configurePaymentExpiringCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    [cell configureDefaultCell];
    
    NSString *total = @"(null)";
    
    cell.titleLabel.text = [NSString stringWithFormat: @"You have %@ expiring soon", total];
    cell.bodyLabel.text = @"Add a payment method to get paid";
}

-(void)configurePaymentSentCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    [cell configureDefaultCell];
    
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
}

-(void)configurePaymentDeclinedCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
}

-(void)configureTaxInfoRequiredCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary{
    
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
}

-(void)configureTaxInfoProcessedCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = [dictionary objectForKey:@"body"];
    
//    if (processed) {
//        cell.titleLabel.text = @"Your tax info was accepted!";
//    } else {
//        [self configureTaxInfoDeclinedCell:cell];
//    }
}

-(void)configureTaxInfoDeclinedCell:(FRSDefaultNotificationTableViewCell *)cell dictionary:(NSDictionary *)dictionary {
    [cell.image removeFromSuperview];
    cell.image = nil;
    
    [cell configureDefaultCell];
    
    cell.titleLabel.text = [dictionary objectForKey:@"title"];
    cell.bodyLabel.text = @"Your tax info was declined.";
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
        if ([notification objectForKey:@"user_id"]) {
            [[FRSAPIClient sharedClient] getUserWithUID:[notification objectForKey:@"user_id"] completion:^(id responseObject, NSError *error) {
                FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
                FRSUser *currentUser = [FRSUser nonSavedUserWithProperties:responseObject context:[delegate managedObjectContext]];
                if ([[responseObject valueForKey:@"following"] boolValue]) {
                    [self unfollowUser:currentUser];
                } else {
                    [self followUser:currentUser];
                }
            }];
        }
    }
}

-(void)followUser:(FRSUser *)user {
    [[FRSAPIClient sharedClient] followUser:user completion:^(id responseObject, NSError *error) {
        
        if (error) {
            // Follow button image automatically changes on tap in the cell to avoid making the user wait for API response, update here if failuer.
            return;
        }
    }];
}

-(void)unfollowUser:(FRSUser *)user {
    [[FRSAPIClient sharedClient] unfollowUser:user completion:^(id responseObject, NSError *error) {
        
        if (error) {
            // Follow button image automatically changes on tap in the cell to avoid making the user wait for API response, update here if failuer.
            return;
        }
    }];
}

// Gets called when the user taps on the right aligned button on assignment notification cells
-(void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    FRSAlertView *alert = [[FRSAlertView alloc] init];
    alert.delegate = self;
    [alert navigateToAssignmentWithLatitude:latitude longitude:longitude];
}


@end
