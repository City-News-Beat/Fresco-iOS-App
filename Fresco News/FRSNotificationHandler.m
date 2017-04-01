
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
#import "CLLocation+Fresco.h"
#import <Smooch/Smooch.h>

static BOOL isDeeplinking;

/* BOOL used to determine if the push handler is navigating to an assignment */
BOOL isSegueingToAssignment;

@implementation FRSNotificationHandler

+ (void)handleNotification:(NSDictionary *)push track:(BOOL)shouldTrack {
    
    NSString *type  = push[TYPE]  ? push[TYPE]  : @"";
    NSString *title = push[TITLE] ? push[TITLE] : @"";
    
    NSMutableDictionary *paramsToTrack = [[NSMutableDictionary alloc] init]; // Create an NSMutableDictionary that will be populated according to the push[TYPE]
    
    
    /* SMOOCH */

    // smoochSupportTempNotification checks are temporary and should be removed when support is added on the web platform for this feature
    if ([type isEqualToString:smoochSupportNotification] || ([title caseInsensitiveCompare:smoochSupportTempNotification] == NSOrderedSame && [title length] != 0)) {
        
        // Setup whisper tracking
        [Smooch track:smoochNotificationEventName];
        
        // Mixpanel track
        [paramsToTrack setObject:type forKey:PUSH_KEY];
        
        // Display Smooch view
        [Smooch show];
    }

    
    /* ASSIGNMENTS */
    
    // New assignment notifications need to be tracked independantly from the others because of the GET request required to fetch the distance away.
    if ([type isEqualToString:newAssignmentNotification]) {
        
        NSString *assignment = [[push objectForKey:META] objectForKey:ASSIGNMENT_ID];
        NSString *assignmentID;
        
        if (assignment && ![assignment isEqual:[NSNull null]] && [[assignment class] isSubclassOfClass:[NSString class]]) {
            assignmentID = assignment;
        } else {
            assignmentID = [push objectForKey:ASSIGNMENT_ID];
        }
        
        // Fetch assignment
        [[FRSAssignmentManager sharedInstance] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
            
            // Handle errors
            if (error) {
                FRSAlertView *alertView = [[FRSAlertView alloc]
                                           initWithTitle:@"Unable to Load Assignment!"
                                           message:@"We're unable to load this assignment right now!"
                                           actionTitle:@"OK"
                                           cancelTitle:@""
                                           cancelTitleColor:[UIColor frescoBackgroundColorDark]
                                           delegate:nil];
                [alertView show];
                
                return;
            }
            
            // Create FRSAssignment object
            FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
            FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:[appDelegate managedObjectContext]];
            [assignment configureWithDictionary:responseObject];
            
            // Configure tracking parameters
            [paramsToTrack setObject:type forKey:PUSH_KEY]; // Add notif-type to tracking dictionary
            [paramsToTrack setObject:ASSIGNMENT forKey:OBJECT]; // Add object type to tracking dictionary
            [paramsToTrack setObject:assignmentID forKey:OBJECT_ID]; // Add object_id to tracking dictionary
            
            if ([[push objectForKey:IS_GLOBAL] boolValue]) { // Check if global
                [paramsToTrack setObject:GLOBAL forKey:DISTANCE_AWAY];
            } else { // Set DISTANCE_AWAY if not global
                [paramsToTrack setObject:@([CLLocation calculatedDistanceFromAssignment:assignment]) forKey:DISTANCE_AWAY];
            }
            
            // Track notificationOpened event only if BOOL shouldTrack is enabled
            [self trackNotification:shouldTrack withParams:paramsToTrack];
            
            NSTimeInterval dateDiff = [assignment.expirationDate timeIntervalSinceDate:[NSDate date]];
            if (dateDiff < 0.0) { // if expired
                FRSAlertView *alertView = [[FRSAlertView alloc]
                                           initWithTitle:@"Assignment Expired"
                                           message:@"This assignment has already expired"
                                           actionTitle:@"OK"
                                           cancelTitle:@""
                                           cancelTitleColor:[UIColor frescoBackgroundColorDark]
                                           delegate:nil];
                [alertView show];
            } else {
                
                // Segue to assignment
                [FRSNotificationHandler segueToAssignment:assignment];
            }
        }];

        return; // return to avoid double call to [FRSTracker track:]
    }

    /* PAYMENT */
    if ([type isEqualToString:purchasedContentNotification]) {
        
        if ([[push[@"meta"] valueForKey:HAS_PAYMENT] boolValue]) {
            [self segueToGallery:[self galleryIDFromPush:push]];
        } else {
            [FRSNotificationHandler segueToPayment];
        }
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
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
    
    
    /* SOCIAL */
    
    if ([type isEqualToString:followedNotification]) {
        NSString *user = [[[push objectForKey:META] objectForKey:USER_IDS] firstObject];
        
        if (user && [[user class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToUser:user];
        } else {
            user = [[push objectForKey:USER_IDS] firstObject];
            [FRSNotificationHandler segueToUser:user];
        }
        [paramsToTrack setObject:USER forKey:OBJECT];
    }
    
    if ([type isEqualToString:likedNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    if ([type isEqualToString:repostedNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    if ([type isEqualToString:galleryApprovedNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    if ([type isEqualToString:commentedNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    if ([type isEqualToString:mentionCommentNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    
    /* NEWS */
    
    if ([type isEqualToString:photoOfDayNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    if ([type isEqualToString:todayInNewsNotification]) {
        NSArray *galleryIDs;
        
        if ([[push objectForKey:META] objectForKey:GALLERY_IDS]) {
            galleryIDs = [[push objectForKey:META] objectForKey:GALLERY_IDS];
        } else {
            galleryIDs = [push objectForKey:GALLERY_IDS];
        }
        [FRSNotificationHandler segueToTodayInNews:galleryIDs title:@"TODAY IN NEWS"];
        
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        // We don't want to track objectID for notifications with multiple objects
    }
    
    if ([type isEqualToString:userNewsStoryNotification]) {
        NSString *story = [[push objectForKey:META] objectForKey:STORY_ID];
        
        if (story && ![story isEqual:[NSNull null]] && [[story class] isSubclassOfClass:[NSString class]]) {
            [FRSNotificationHandler segueToStory:story];
        } else {
            NSString *story = [push objectForKey:STORY_ID];
            [FRSNotificationHandler segueToGallery:story];
        }
        [paramsToTrack setObject:STORY forKey:OBJECT];
        [paramsToTrack setObject:STORY_ID forKey:OBJECT_ID];
    }
    
    if ([type isEqualToString:userNewsGalleryNotification]) {
        [paramsToTrack setObject:GALLERY forKey:OBJECT];
        [paramsToTrack setObject:[self galleryIDFromPush:push] forKey:OBJECT_ID];
        [FRSNotificationHandler segueToGallery:[self galleryIDFromPush:push]];
    }
    
    
    [paramsToTrack setObject:type forKey:PUSH_KEY]; // Track PUSH_KEY by default
    [self trackNotification:shouldTrack withParams:paramsToTrack];
}


/**
 This method checks if track is enabled before calling [FRSTracker track:]
 
 @param params NSDictionary of parameters that should be tracked with the notificationOpened event.
 */
+ (void)trackNotification:(BOOL)shouldTrack withParams:(NSDictionary *)params {
    if (shouldTrack) {
        [FRSTracker track:notificationOpened parameters:params];
    }
}


/**
 Checks the given dictionary and returns a valid string.
 
 @param push NSDictionary from a push notification
 @return NSString galleryID
 */
+ (NSString *)galleryIDFromPush:(NSDictionary *)push {
    
    NSString *response = [[push objectForKey:META] objectForKey:GALLERY_ID];
    NSString *galleryID;
    
    // The gallery ID is sometimes under 'meta' and other times directly in the push dictionary.
    // This checks 'meta' first and falls back on the push dictionary.
    if (response && ![response isEqual:[NSNull null]] && [[response class] isSubclassOfClass:[NSString class]]) {
        galleryID = response;
    } else {
        galleryID = [push objectForKey:GALLERY_ID];
    }
    
    return galleryID;
}


+ (void)segueToPhotosOfTheDay:(NSArray *)postIDs {
    // This is not setup on the API yet.
}

+ (void)segueToTodayInNews:(NSArray *)galleryIDs title:(NSString *)title {
    
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UITabBarController *tab = (UITabBarController *)appDelegate.tabBarController;
    FRSStoryDetailViewController *detailVC = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailVC.isComingFromNotification = YES;
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
    detailVC.trackedScreen = FRSTrackedScreenPush;

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
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       detailVC.gallery = galleryToSave;
                                                       [detailVC viewDidLoad];
                                                   });
                                               }];
}

// TODO: Reuse these errors
+ (void)error:(NSError *)error {
    if (!error) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"Unable to load gallery. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:nil delegate:nil];
        [alert show];
    } else if (error.code == -1009) {
        FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
        [alert show];
    } else {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"This gallery could not be found, or does not exist." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:nil delegate:nil];
        [alert show];
    }
}

+ (void)segueToStory:(NSString *)storyID {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UITabBarController *tab = (UITabBarController *)appDelegate.tabBarController;
    FRSStoryDetailViewController *detailVC = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailVC.isComingFromNotification = YES;
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
    detailView.isComingFromNotification = YES;
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

+ (void)segueToAssignment:(FRSAssignment *)assignment {
    
    if (isSegueingToAssignment) {
        return;
    }
    
    isSegueingToAssignment = YES;
    
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
        UITabBarController *tab = (UITabBarController *)[[navController viewControllers] firstObject];
        tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
        tab.navigationController.interactivePopGestureRecognizer.delegate = nil;
        
        FRSAssignmentsViewController *assignmentsVC = (FRSAssignmentsViewController *)[[(FRSNavigationController *)[tab.viewControllers objectAtIndex:3] viewControllers] firstObject];
        
        assignmentsVC.assignmentCardIsOpen = YES;
        assignmentsVC.hasDefault = YES;
        assignmentsVC.defaultID = assignment.uid;
        
        [assignmentsVC.navigationController setNavigationBarHidden:FALSE];
        assignmentsVC.selectedAssignment = assignment;
        
        navController = (UINavigationController *)[[tab viewControllers] objectAtIndex:2];
        [tab setSelectedIndex:3];
    }
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
