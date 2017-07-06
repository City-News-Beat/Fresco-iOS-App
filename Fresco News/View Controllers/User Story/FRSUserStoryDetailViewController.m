//
//  FRSUserStoryDetailViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailViewController.h"
#import "FRSUserStoryDetailTableView.h"
#import "FRSActionBar.h"
#import "FRSModerationManager.h"
#import "FRSModerationAlertView.h"
#define FOOT_PADDING 100

@interface FRSUserStoryDetailViewController () <FRSActionBarDelegate, FRSUserStoryDetailTableViewDelegate, FRSAlertViewDelegate>

@property (strong, nonatomic) FRSUserStory *userStory;

// TODO: Move moderation into it's own class. The view controller should not handle any of this logic.
@property (strong, nonatomic) NSDictionary *currentCommentUserDictionary;
@property BOOL didDisplayReport;
@property BOOL didDisplayBlock;
@property BOOL didBlockUser;
@property BOOL isReportingComment;
@property BOOL isBlockingFromComment;
@property (strong, nonatomic) FRSModerationAlertView *reportUserAlertView;
@property (strong, nonatomic) NSString *reportReasonString;

@end

@implementation FRSUserStoryDetailViewController

- (instancetype)initWithUserStory:(FRSUserStory *)userStory {
    self = [super init];
    if (self) {
        self.userStory = userStory;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureNavigationBar];
    [self configureTableView];
    [self configureActionBar];
    
    [self hideTabBarAnimated:YES];
}

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    
    // TODO: Consolidate the navigation bar formatting logic into one place.
    // Ideally we would just use self.navigationController, but it's nil for some reason. Needs to be debugged, might have to do with presenting an nib.
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBar = (UITabBarController *)appDelegate.tabBarController;
    UINavigationController *nav = [tabBar.viewControllers firstObject];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName :[UIFont notaBoldWithSize:17]}];
    
    self.title = @"STORY"; // This should be "CITY, STATE". Pending API.
}

- (void)configureTableView {
    FRSUserStoryDetailTableView *tableView = [[FRSUserStoryDetailTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - FOOT_PADDING) userStory:self.userStory];
    tableView.delegate = self;
    [self.view addSubview:tableView];
}

- (void)configureActionBar {
    FRSActionBar *actionBar = [[FRSActionBar alloc] initWithOrigin:CGPointMake(0, self.view.frame.size.height - 44) delegate:self];
    [self.view addSubview:actionBar];
}

#pragma mark - FRSUserStoryDetailTableViewDelegate

// TODO: Move moderation into it's own class. The view controller should not handle any of this logic.

- (void)reportUserAlertAction {
    NSString *username = @"";
    
    if ([self.userStory.creator.username class] != [NSNull null] && (![self.userStory.creator.username isEqualToString:@"<null>"])) {
        username = [NSString stringWithFormat:@"@%@", self.userStory.creator.username];
    } else if (self.currentCommentUserDictionary[@"full_name"] != [NSNull null] && (![self.userStory.creator.firstName isEqualToString:@"<null>"])) {
        username = self.userStory.creator.firstName;
    } else {
        username = @"them";
    }
    
    if (self.isReportingComment) {
        [self reportUser:self.currentCommentUserDictionary[@"id"]];
    } else {
        [self reportUser:self.userStory.creator.uid];
    }
}

- (void)didPressRadioButtonAtIndex:(NSInteger)index {
    if (self.reportUserAlertView /*|| self.galleryReportAlertView*/) {
        switch (index) {
            case 0:
                self.reportReasonString = @"abuse";
                break;
            case 1:
                self.reportReasonString = @"spam";
                break;
            case 2:
                self.reportReasonString = @"stolen";
                break;
            case 3:
                self.reportReasonString = @"nsfw";
                break;
            default:
                break;
        }
    }
}

- (void)reportComment:(FRSComment *)comment {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.currentCommentUserDictionary = comment.userDictionary;
    
    NSLog(@"userDictionary: %@", comment.userDictionary);
    
    NSString *username;
    
    if (comment.userDictionary[@"username"] != [NSNull null] && (![comment.userDictionary[@"username"] isEqualToString:@"<null>"])) {
        username = [NSString stringWithFormat:@"@%@", comment.userDictionary[@"username"]];
    } else if (comment.userDictionary[@"full_name"] != [NSNull null] && (![comment.userDictionary[@"full_name"] isEqualToString:@"<null>"])) {
        username = comment.userDictionary[@"full_name"];
    } else {
        username = @"them";
    }
    
    UIAlertAction *block = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Block %@", username]
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      
                                                      [[FRSModerationManager sharedInstance] blockUser:comment.userDictionary[@"id"]
                                                                                        withCompletion:^(id responseObject, NSError *error) {
                                                                                            
                                                                                            if (responseObject) {
                                                                                                FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"BLOCKED" message:[NSString stringWithFormat:@"You won’t see posts from %@ anymore.", username] actionTitle:@"UNDO" cancelTitle:@"OK" cancelTitleColor:nil delegate:self];
                                                                                                self.didDisplayBlock = YES;
                                                                                                [alert show];
                                                                                                self.isBlockingFromComment = YES;
                                                                                                
                                                                                            } else {
                                                                                                [self presentGenericError];
                                                                                            }
                                                                                        }];
                                                      
                                                      [view dismissViewControllerAnimated:YES completion:nil];
                                                  }];
    
    UIAlertAction *unblock = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Unblock %@", username]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        
                                                        [[FRSModerationManager sharedInstance] unblockUser:comment.userDictionary[@"id"]
                                                                                            withCompletion:^(id responseObject, NSError *error) {
                                                                                                
                                                                                                if (responseObject) {
                                                                                                    
                                                                                                } else {
                                                                                                    [self presentGenericError];
                                                                                                }
                                                                                            }];
                                                        
                                                        [view dismissViewControllerAnimated:YES completion:nil];
                                                    }];
    
    UIAlertAction *report = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Report %@", username]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       
                                                       self.isReportingComment = YES;
                                                       self.reportUserAlertView = [[FRSModerationAlertView alloc] initUserReportWithUsername:[NSString stringWithFormat:@"%@", username] delegate:self];
                                                       self.reportUserAlertView.delegate = self;
                                                       self.didDisplayReport = YES;
                                                       [self.reportUserAlertView show];
                                                       
                                                       [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {
                                                       
                                                       [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [view addAction:report];
    
    if (![comment.userDictionary[@"blocked"] boolValue]) {
        [view addAction:block];
    } else {
        [view addAction:unblock];
    }
    
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - Moderation

- (void)blockUser:(FRSUser *)user {
    [[FRSModerationManager sharedInstance] blockUser:user.uid
                                      withCompletion:^(id responseObject, NSError *error) {
                                          
                                          if (responseObject) {
                                              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"BLOCKED" message:[NSString stringWithFormat:@"You won’t see posts from %@ anymore.", user.username] actionTitle:@"UNDO" cancelTitle:@"OK" cancelTitleColor:nil delegate:self];
                                              self.didDisplayBlock = YES;
                                              [alert show];
                                              self.didBlockUser = YES;
                                              self.isBlockingFromComment = NO;
                                          } else {
                                              [self presentGenericError];
                                          }
                                      }];
}

- (void)unblockUser:(NSString *)userID {
    [[FRSModerationManager sharedInstance] unblockUser:userID
                                        withCompletion:^(id responseObject, NSError *error) {
                                            
                                            if (responseObject) {
                                                self.didBlockUser = NO;
                                            }
                                            
                                            if (error) {
                                                [self presentGenericError];
                                            }
                                        }];
}

- (void)reportUser:(NSString *)userID {
    [[FRSModerationManager sharedInstance] reportUser:userID
                                               params:@{ @"reason" : self.reportReasonString,
                                                         @"message" : self.reportUserAlertView.textView.text }
                                           completion:^(id responseObject, NSError *error) {
                                               
                                               if (error) {
                                                   [self presentGenericError];
                                                   return;
                                               }
                                               
                                               if (responseObject) {
                                                   
                                                   NSString *username = @"";
                                                   
                                                   if (self.isReportingComment) {
                                                       
                                                       if (self.currentCommentUserDictionary[@"username"] != [NSNull null] && (![self.currentCommentUserDictionary[@"username"] isEqualToString:@"<null>"])) {
                                                           username = [NSString stringWithFormat:@"@%@", self.currentCommentUserDictionary[@"username"]];
                                                       } else if (self.currentCommentUserDictionary[@"full_name"] != [NSNull null] && (![self.currentCommentUserDictionary[@"full_name"] isEqualToString:@"<null>"])) {
                                                           username = self.currentCommentUserDictionary[@"full_name"];
                                                       } else {
                                                           username = @"them";
                                                       }
                                                   } else {
                                                       
                                                       if ([self.userStory.creator.username class] != [NSNull null] && (![self.userStory.creator.username isEqualToString:@"<null>"])) {
                                                           username = [NSString stringWithFormat:@"@%@", self.userStory.creator.username];
                                                       } else if ([self.userStory.creator.firstName class] != [NSNull null] && (![self.userStory.creator.firstName isEqualToString:@"<null>"])) {
                                                           username = self.userStory.creator.firstName;
                                                       } else {
                                                           username = @"them";
                                                       }
                                                   }
                                                   
                                                   FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"REPORT SENT" message:[NSString stringWithFormat:@"Thanks for helping make Fresco a better community! Would you like to block %@ as well?", username] actionTitle:@"CLOSE" cancelTitle:@"BLOCK USER" cancelTitleColor:nil delegate:self];
                                                   [alert show];
                                               }
                                           }];
}

@end
