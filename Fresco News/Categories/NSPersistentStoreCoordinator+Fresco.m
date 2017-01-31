//
//  NSPersistentStoreCoordinator+Fresco.m
//  Fresco
//
//  Created by Omar Elfanek on 1/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "NSPersistentStoreCoordinator+Fresco.h"

@implementation NSPersistentStoreCoordinator_Fresco

// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
+ (NSPersistentStoreCoordinator *)createCoordinatorWithUrl:(NSURL *)applicationURL {

    // Create the coordinator and store
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinatorToReturn = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSURL *storeURL = [applicationURL URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![coordinatorToReturn addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return coordinatorToReturn;
}

@end
