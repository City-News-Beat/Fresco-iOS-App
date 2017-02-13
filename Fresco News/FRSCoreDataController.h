//
//  FRSCoreDataController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSCoreDataController : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;


/**
 Initializes coredata for us
 */
- (void)initializeCoreData;


/**
 Save context in the managed context model
 */
- (void)saveContext;


/**
 Saves context witha  completion handler

 @param completion completion block returning success or failre
 */
- (void)saveContextSynchornously;

/**
 The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
 
 @param applicationURL applicatonURL
 @return Returns an NSPersistentStoreCoordinate
 */
+ (NSPersistentStoreCoordinator *)createCoordinatorWithUrl;

- (NSURL *)applicationDocumentsDirectory;

@end
