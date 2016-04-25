//
//  FRSAppDelegate.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>

@interface FRSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
@end
