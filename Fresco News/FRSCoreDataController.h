//
//  FRSCoreDataController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSCoreDataController : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 Save context in the managed context model
 */
- (void)saveContext;

/**
 Saves context witha  completion handler

 @param completion completion block returning success or failre
 */
- (void)saveContextSynchornously;

- (NSURL *)applicationDocumentsDirectory;

@end
