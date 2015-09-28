//
//  AppDelegate+Additons.h
//  Fresco
//
//  Created by Fresco News on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Additions)

/**
 *  Opens a gallery in the app, from a push notification
 *
 *  @param galleryId The ID of the gallery pento o
 */

- (void)openGalleryFromPush:(NSString *)galleryId;

/**
 *  Opens an assignment in the app, from a push notification
 *
 *  @param assignmentId The ID of the assignment to open
 *  @param navigation   BOOL to open the navigation dialog when openining assignment
 */

- (void)openAssignmentFromPush:(NSString *)assignmentId withNavigation:(BOOL)navigation;

/**
 *  Opens a list of galleries in the app
 *
 *  @param galleries Array of Gallery IDs to open in a list
 *  @param navTitle  The title of the navigation bar for the list of galleries
 */
- (void)openGalleryListFromPush:(NSArray *)galleries withTitle:(NSString *)navTitle;

@end
