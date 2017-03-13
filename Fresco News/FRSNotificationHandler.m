
//
//  FRSNotificationHandler.m
//  Fresco
//
//  Created by Philip Bernstein on 11/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSNotificationHandler.h"
#import "FRSStoryDetailViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSProfileViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSIdentityViewController.h"
#import "FRSStoryManager.h"
#import "FRSAssignmentManager.h"
#import "FRSGalleryManager.h"
#import "FRSConnectivityAlertView.h"

static BOOL isDeeplinking;

/* BOOL used to determine if the push handler is navigating to an assignment */
static BOOL isSegueingToAssignment;

@implementation FRSNotificationHandler

+ (void)handleNotification:(NSDictionary *)push {
    NSString *type = push[@"type"];
    NSString *title = push[@"title"];

    // smooch

    // smoochSupportTempNotification checks are temporary and should be removed when support is added on the web platform for this feature
    if ([type isEqualToString:smoochSupportNotification] || ([title caseInsensitiveCompare:smoochSupportTempNotification] == NSOrderedSame) || ([title caseInsensitiveCompare:smoochSupportTempNotification] == NSOrderedSame)) {
        [Smooch track:smoochNotificationEventName];
        [Smooch show];
        return;
    }

    // payment
    if ([type isEqualToString:newAssignmentNotification]) {
        NSString *assignment = [[push objectForKey:@"meta"] objectForKey:@"assignment_id"];

        if (assignment && ![assignment isEqual:[NSNull null]] && [[assignment class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToAssignment:assignment];
        } else {
            NSString *assignment = [push objectForKey:@"assignment_id"];
            [FRSNotificationHandler segueToAssignment:assignment];
        }

        return;
    }

    if ([type isEqualToString:purchasedContentNotification]) {
        if ([[push valueForKey:@"has_payment"] boolValue]) {
            NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

            if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
                [self segueToGallery:gallery];
            } else {
                NSString *gallery = [push objectForKey:@"gallery_id"];
                [self segueToGallery:gallery];
            }
        } else {
            [FRSNotificationHandler segueToPayment];
        }
    }

    if ([type isEqualToString:paymentExpiringNotification]) {
        [FRSNotificationHandler segueToPayment];
    }

    if ([type isEqualToString:paymentSentNotification]) {
        [FRSNotificationHandler segueToPayment];
    }

    if ([type isEqualToString:taxInfoRequiredNotification]) {
        [FRSNotificationHandler segueToIdentification];
    }

    if ([type isEqualToString:taxInfoDeclinedNotification]) {
        [FRSNotificationHandler segueToIdentification];
    }

    if ([type isEqualToString:taxInfoProcessedNotification]) {
        [FRSNotificationHandler segueToIdentification];
    }

    if ([type isEqualToString:paymentDeclinedNotification]) {
        [FRSNotificationHandler segueToPayment];
    }

    // social
    if ([type isEqualToString:followedNotification]) {
        NSString *user = [[[push objectForKey:@"meta"] objectForKey:@"user_ids"] firstObject];

        if (user && [[user class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToUser:user];
        } else {
            user = [[push objectForKey:@"user_ids"] firstObject];
            [FRSNotificationHandler segueToUser:user];
        }
    }

    if ([type isEqualToString:@"user-news-gallery"]) {
        NSString *galleryID = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (galleryID && [[galleryID class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:galleryID];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([type isEqualToString:@"user-news-story"]) {
        NSString *story = [[push objectForKey:@"meta"] objectForKey:@"story_id"];

        if (story && ![story isEqual:[NSNull null]] && [[story class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToStory:story];
        } else {
            NSString *story = [push objectForKey:@"story_id"];
            [FRSNotificationHandler segueToGallery:story];
        }
    }

    if ([type isEqualToString:@"user-social-gallery-liked"]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([type isEqualToString:repostedNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([type isEqualToString:galleryApprovedNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([type isEqualToString:commentedNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([type isEqualToString:photoOfDayNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([type isEqualToString:todayInNewsNotification]) {
        NSArray *galleryIDs;

        if ([[push objectForKey:@"meta"] objectForKey:@"gallery_ids"]) {
            galleryIDs = [[push objectForKey:@"meta"] objectForKey:@"gallery_ids"];
        } else {
            galleryIDs = [push objectForKey:@"gallery_ids"];
        }
        [FRSNotificationHandler segueToTodayInNews:galleryIDs title:@"TODAY IN NEWS"];
    }

    if ([type isEqualToString:restartUploadNotification]) {
        [FRSNotificationHandler restartUpload];
    }

    if ([type isEqualToString:@"user-social-mentioned-comment"]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }
}

+ (void)restartUpload {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate restartUpload];
}

+ (void)segueToPhotosOfTheDay:(NSArray *)postIDs {
    //Not part of the initial 3.0 release
}

+ (void)segueToTodayInNews:(NSArray *)galleryIDs title:(NSString *)title {

    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    UITabBarController *tab = (UITabBarController *)appDelegate.tabBarController;
    FRSStoryDetailViewController *detailVC = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];

    detailVC.navigationController = tab.navigationController;
    detailVC.title = title;
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    [navController setNavigationBarHidden:FALSE];

    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {

    } else {
        UITabBarController *tab = (UITabBarController *)navController;
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController setNavigationBarHidden:FALSE];
    }

    NSMutableArray *galleryArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < [galleryIDs count]; i++) {

        [[FRSGalleryManager sharedInstance] getGalleryWithUID:[galleryIDs objectAtIndex:i]
                                                   completion:^(id responseObject, NSError *error) {
                                                     if (!error && responseObject) {
                                                         [galleryArray addObject:responseObject];

                                                         // Checks if loop is complete by comparing added galleries with gallery IDs
                                                         if ([galleryArray count] == [galleryIDs count]) {

                                                             // If all galleries from the galleryIDs array have been adedd, push and configure
                                                             [detailVC configureWithGalleries:galleryArray];
                                                             [navController pushViewController:detailVC animated:TRUE];
                                                         }
                                                     } else {
                                                         NSLog(@"Unable to create gallery from id: %@", [galleryIDs objectAtIndex:i]);
                                                     }
                                                   }];
    }
}

+ (void)segueToGallery:(NSString *)galleryID {
    __block BOOL isPushingGallery = FALSE;
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    FRSGalleryExpandedViewController *detailVC = [[FRSGalleryExpandedViewController alloc] init];
    [detailVC configureBackButtonAnimated:YES];
    detailVC.openedFrom = @"push";

    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
        [navController pushViewController:detailVC animated:TRUE];
        [navController setNavigationBarHidden:FALSE];
    } else {
        UITabBarController *tab = (UITabBarController *)navController;
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController pushViewController:detailVC animated:TRUE];
        [navController setNavigationBarHidden:FALSE];
    }

    [[FRSGalleryManager sharedInstance] getGalleryWithUID:galleryID
                                               completion:^(id responseObject, NSError *error) {
                                                 if (error || !responseObject) {
                                                     [self error:error];
                                                     return;
                                                 }

                                                 if (isPushingGallery) {
                                                     return;
                                                 }

                                                 isPushingGallery = TRUE;

                                                 FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[appDelegate managedObjectContext]];

                                                 [galleryToSave configureWithDictionary:responseObject context:[appDelegate managedObjectContext]];
                                               }];
}

+ (void)error:(NSError *)error {
    if (!error) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"Unable to load gallery. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    } else if (error.code == -1009) {
        FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
        [alert show];
    } else {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"This gallery could not be found, or does not exist." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    }
}

+ (void)segueToStory:(NSString *)storyID {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    UITabBarController *tab = (UITabBarController *)appDelegate.tabBarController;
    FRSStoryDetailViewController *detailVC = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];

    detailVC.navigationController = tab.navigationController;
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    [navController setNavigationBarHidden:FALSE];

    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
        [navController pushViewController:detailVC animated:TRUE];
    } else {
        UITabBarController *tab = (UITabBarController *)navController;
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController setNavigationBarHidden:FALSE];
        [navController pushViewController:detailVC animated:TRUE];
    }

    // __block BOOL isSegueingToStory;

    [[FRSStoryManager sharedInstance] getStoryWithUID:storyID
                                           completion:^(id responseObject, NSError *error) {
                                             if (error) {
                                                 [self error:error];
                                             }

                                             FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:[appDelegate managedObjectContext]];
                                             [story configureWithDictionary:responseObject];

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                               detailVC.story = story;
                                               [detailVC reloadData];
                                             });
                                           }];
}

+ (FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

+ (void)segueToUser:(NSString *)userID {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    FRSProfileViewController *profileVC = [[FRSProfileViewController alloc] initWithUserID:userID];
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
        UITabBarController *tab = (UITabBarController *)navController.viewControllers[0];
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        // [navController setNavigationBarHidden:FALSE];
        navController = (UINavigationController *)tab.selectedViewController;
        [navController pushViewController:profileVC animated:TRUE];
    } else {
        UITabBarController *tab = (UITabBarController *)navController;
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        // [navController setNavigationBarHidden:FALSE];
        navController = (UINavigationController *)tab.selectedViewController;
        [navController pushViewController:profileVC animated:TRUE];
    }
}

- (void)popViewController {
}

+ (void)popViewController {
}

+ (void)segueToAssignment:(NSString *)assignmentID {

    if (isSegueingToAssignment) {
        return;
    }

    isSegueingToAssignment = YES;

    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.3];

    [[FRSAssignmentManager sharedInstance] getAssignmentWithUID:assignmentID
                                                     completion:^(id responseObject, NSError *error) {

                                                       //Tell the view controller we're done with this segue
                                                       isSegueingToAssignment = NO;

                                                       if (error) {
                                                           FRSAlertView *alertView = [[FRSAlertView alloc]
                                                                  initWithTitle:@"Unable to Load Assignment!"
                                                                        message:@"We're unable to load this assignment right now!"
                                                                    actionTitle:@"OK"
                                                                    cancelTitle:@""
                                                               cancelTitleColor:[UIColor frescoBackgroundColorDark]
                                                                       delegate:nil];
                                                           [alertView.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
                                                           [alertView show];

                                                           return;
                                                       }

                                                       FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:[appDelegate managedObjectContext]];

                                                       UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

                                                       [assignment configureWithDictionary:responseObject];

                                                       NSTimeInterval dateDiff = [assignment.expirationDate timeIntervalSinceDate:[NSDate date]];
                                                       if (dateDiff < 0.0) { // if expired
                                                           FRSAlertView *alertView = [[FRSAlertView alloc]
                                                                  initWithTitle:@"Assignment Expired"
                                                                        message:@"This assignment has already expired"
                                                                    actionTitle:@"OK"
                                                                    cancelTitle:@""
                                                               cancelTitleColor:[UIColor frescoBackgroundColorDark]
                                                                       delegate:nil];
                                                           [alertView.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
                                                           [alertView show];
                                                       } else {
                                                           if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
                                                               UITabBarController *tab = (UITabBarController *)[[navController viewControllers] firstObject];
                                                               tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
                                                               tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

                                                               FRSAssignmentsViewController *assignmentsVC = (FRSAssignmentsViewController *)[[(FRSNavigationController *)[tab.viewControllers objectAtIndex:3] viewControllers] firstObject];

                                                               assignmentsVC.assignmentCardIsOpen = YES;
                                                               assignmentsVC.hasDefault = YES;
                                                               assignmentsVC.defaultID = assignmentID;

                                                               [assignmentsVC.navigationController setNavigationBarHidden:FALSE];
                                                               assignmentsVC.selectedAssignment = assignment;

                                                               navController = (UINavigationController *)[[tab viewControllers] objectAtIndex:2];
                                                               [tab setSelectedIndex:3];
                                                           }
                                                       }
                                                     }];
}

+ (void)segueToPayment {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    FRSDebitCardViewController *debitCardVC = [[FRSDebitCardViewController alloc] init];
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
        UITabBarController *tab = (UITabBarController *)navController.viewControllers[0];
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        [navController setNavigationBarHidden:FALSE];
        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController pushViewController:debitCardVC animated:TRUE];

        [tab setSelectedIndex:0];
    } else {
        UITabBarController *tab = (UITabBarController *)navController;
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController pushViewController:debitCardVC animated:TRUE];
        [navController setNavigationBarHidden:FALSE];
    }
}

+ (void)segueToIdentification {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    FRSIdentityViewController *taxVC = [[FRSIdentityViewController alloc] init];
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
        UITabBarController *tab = (UITabBarController *)navController.viewControllers[0];
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        [navController setNavigationBarHidden:FALSE];
        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController pushViewController:taxVC animated:TRUE];

        [tab setSelectedIndex:0];
    } else {
        UITabBarController *tab = (UITabBarController *)navController;
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

        navController = (UINavigationController *)[[tab viewControllers] firstObject];
        [navController pushViewController:taxVC animated:TRUE];
        [navController setNavigationBarHidden:FALSE];
    }
}

// DEEP LINKING
+ (BOOL)isDeeplinking {
    return isDeeplinking;
}

+ (void)setIsDeeplinking:(BOOL)value {
    isDeeplinking = value;
}

@end
