//
//  FRSNotificationHandler.m
//  Fresco
//
//  Created by Philip Bernstein on 11/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSNotificationHandler.h"
#import "FRSStoryDetailViewController.h"
#import "FRSAppDelegate.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSProfileViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSIdentityViewController.h"
#import "Fresco.h"

static BOOL isDeeplinking;

@implementation FRSNotificationHandler

+ (void)handleNotification:(NSDictionary *)push {
    NSString *instruction = push[@"type"];

    // payment
    if ([instruction isEqualToString:newAssignmentNotification]) {
        NSString *assignment = [[push objectForKey:@"meta"] objectForKey:@"assignment_id"];

        if (assignment && ![assignment isEqual:[NSNull null]] && [[assignment class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToAssignment:assignment];
        } else {
            NSString *assignment = [push objectForKey:@"assignment_id"];
            [FRSNotificationHandler segueToAssignment:assignment];
        }

        return;
    }
    if ([instruction isEqualToString:purchasedContentNotification]) {
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

    if ([instruction isEqualToString:paymentExpiringNotification]) {
        [FRSNotificationHandler segueToPayment];
    }

    if ([instruction isEqualToString:paymentSentNotification]) {
        [FRSNotificationHandler segueToPayment];
    }

    if ([instruction isEqualToString:taxInfoRequiredNotification]) {
        [FRSNotificationHandler segueToIdentification];
    }

    if ([instruction isEqualToString:taxInfoDeclinedNotification]) {
        [FRSNotificationHandler segueToIdentification];
    }

    if ([instruction isEqualToString:taxInfoProcessedNotification]) {
        [FRSNotificationHandler segueToIdentification];
    }

    if ([instruction isEqualToString:paymentDeclinedNotification]) {
        [FRSNotificationHandler segueToPayment];
    }

    // social
    if ([instruction isEqualToString:followedNotification]) {
        NSString *user = [[[push objectForKey:@"meta"] objectForKey:@"user_ids"] firstObject];

        if (user && [[user class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToUser:user];
        } else {
            user = [[push objectForKey:@"user_ids"] firstObject];
            [FRSNotificationHandler segueToUser:user];
        }
    }

    if ([instruction isEqualToString:@"user-news-gallery"]) {
        NSString *galleryID = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (galleryID && [[galleryID class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:galleryID];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([instruction isEqualToString:@"user-news-story"]) {
        NSString *story = [[push objectForKey:@"meta"] objectForKey:@"story_id"];

        if (story && ![story isEqual:[NSNull null]] && [[story class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToStory:story];
        } else {
            NSString *story = [push objectForKey:@"story_id"];
            [FRSNotificationHandler segueToGallery:story];
        }
    }

    if ([instruction isEqualToString:@"user-social-gallery-liked"]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([instruction isEqualToString:repostedNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([instruction isEqualToString:galleryApprovedNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([instruction isEqualToString:commentedNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([instruction isEqualToString:photoOfDayNotification]) {
        NSString *gallery = [[push objectForKey:@"meta"] objectForKey:@"gallery_id"];

        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToGallery:gallery];
        } else {
            NSString *gallery = [push objectForKey:@"gallery_id"];
            [FRSNotificationHandler segueToGallery:gallery];
        }
    }

    if ([instruction isEqualToString:todayInNewsNotification]) {
        NSArray *galleryIDs = [[push objectForKey:@"meta"] objectForKey:@"gallery_ids"];

        if (galleryIDs && [[galleryIDs class] isSubclassOfClass:[galleryIDs class]]) {
            [FRSNotificationHandler segueToTodayInNews:galleryIDs title:push[@"aps"][@"alert"][@"title"]];
        } else {
            NSArray *galleryIDs = [push objectForKey:@"gallery_ids"];
            [FRSNotificationHandler segueToTodayInNews:galleryIDs title:@"Today In News"];
        }
    }

    if ([instruction isEqualToString:restartUploadNotification]) {
        [FRSNotificationHandler restartUpload];
    }

    if ([instruction isEqualToString:@"user-social-mentioned-comment"]) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notif-for-todayinnews" object:galleryIDs];
}

+ (void)segueToGallery:(NSString *)galleryID {
    __block BOOL isPushingGallery = FALSE;
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    FRSGalleryExpandedViewController *detailVC = [[FRSGalleryExpandedViewController alloc] init];
    detailVC.shouldHaveBackButton = YES;
    detailVC.openedFrom = @"Push";

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

    [[FRSAPIClient sharedClient] getGalleryWithUID:galleryID
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

                                          dispatch_async(dispatch_get_main_queue(), ^{
                                            [detailVC loadGallery:galleryToSave];
                                          });
                                        }];
}

+ (void)error:(NSError *)error {
    if (!error) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"Unable to load gallery. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    } else if (error.code == -1009) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"CONNECTION ERROR" message:@"Unable to connect to the internet. Please check your connection and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
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

    [[FRSAPIClient sharedClient] getStoryWithUID:storyID
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

+ (void)segueToGallery:(NSString *)gallery post:(NSString *)post {

    [[FRSAPIClient sharedClient] getPostWithID:post
                                    completion:^(id responseObject, NSError *error){

                                    }];
}

+ (void)segueToAssignment:(NSString *)assignmentID {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.tabBarController setSelectedIndex:3];

    [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.3];
    __block BOOL ranOnce = FALSE;

    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID
                                           completion:^(id responseObject, NSError *error) {
                                             if (ranOnce) {
                                                 return;
                                             }

                                             ranOnce = TRUE;
                                             FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:[appDelegate managedObjectContext]];

                                             UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

                                             if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
                                                 UITabBarController *tab = (UITabBarController *)[[navController viewControllers] firstObject];
                                                 tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
                                                 tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

                                                 FRSAssignmentsViewController *assignmentsVC = (FRSAssignmentsViewController *)[[(FRSNavigationController *)[tab.viewControllers objectAtIndex:3] viewControllers] firstObject];

                                                 assignmentsVC.hasDefault = YES;
                                                 assignmentsVC.defaultID = assignmentID;

                                                 [assignmentsVC.navigationController setNavigationBarHidden:FALSE];

                                                 [assignment configureWithDictionary:responseObject];
                                                 [assignmentsVC focusOnAssignment:assignment];

                                                 navController = (UINavigationController *)[[tab viewControllers] objectAtIndex:2];
                                                 [tab setSelectedIndex:3];
                                             } else {
                                                 UITabBarController *tab = (UITabBarController *)navController;
                                                 tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
                                                 tab.navigationController.interactivePopGestureRecognizer.delegate = nil;

                                                 FRSAssignmentsViewController *assignmentsVC = (FRSAssignmentsViewController *)[[(FRSNavigationController *)[tab.viewControllers objectAtIndex:3] viewControllers] firstObject];

                                                 assignmentsVC.hasDefault = YES;
                                                 assignmentsVC.defaultID = assignmentID;

                                                 [assignmentsVC.navigationController setNavigationBarHidden:FALSE];

                                                 [assignment configureWithDictionary:responseObject];
                                                 [assignmentsVC focusOnAssignment:assignment];

                                                 navController = (UINavigationController *)[[tab.tabBarController viewControllers] objectAtIndex:2];
                                                 [tab setSelectedIndex:3];
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
