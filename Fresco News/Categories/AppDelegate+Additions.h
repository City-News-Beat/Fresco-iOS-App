//
//  AppDelegate+Additons.h
//  Fresco
//
//  Created by Fresco News on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Additions)

- (void)openGalleryFromPush:(NSString *)galleryId;

- (void)openAssignmentFromPush:(NSString *)assignmentId withNavigation:(BOOL)navigation;

- (void)openGalleryListFromPush:(NSArray *)galleries withTitle:(NSString *)navTitle;

@end
