//
//  FRSCoreDataController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCoreDataController.h"

@implementation FRSCoreDataController

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    [self initializeCoreData];
    
    return self;
}


- (void)initializeCoreData
{
    // Create the coordinator and store
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };

    NSPersistentStoreCoordinator *psc = [FRSCoreDataController createCoordinatorWithUrl];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}


+ (NSPersistentStoreCoordinator *)createCoordinatorWithUrl {
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSAssert(managedObjectModel != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *coordinatorToReturn = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    return coordinatorToReturn;
}
                                         
- (NSURL *)applicationDocumentsDirectory{
     // The directory the application uses to store the Core Data store file. This code uses a directory named "com.opentoggle.c" in the application's documents directory.
     return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 }

- (void)saveContext {
    if ([self managedObjectContext] != nil) {
        NSError *error = nil;
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


- (void)saveContextSynchornously{
    [self.managedObjectContext performBlockAndWait:^{
        [self saveContext];
    }];
}

@end
