//
//  FRSPersistence.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>

/* 
    Types of managed objects we deal with (subclass, custom ivars)
    We import the categories b/c the categories already import their respective classes000000
 */

#import "FRSArticle+CoreDataProperties.h"
#import "FRSUser+CoreDataProperties.h"
#import "FRSAssignment+CoreDataProperties.h"
#import "FRSStory+CoreDataProperties.h"
#import "FRSNotification+CoreDataProperties.h"
#import "FRSGallery+CoreDataProperties.h"
#import "FRSPost+CoreDataProperties.h"

typedef void(^FRSCachePutCompletionBlock)(NSManagedObject *managedObject, NSManagedObjectContext *context, NSError *error);
typedef void(^FRSCachePullCompletionBlock)(NSArray *results, NSManagedObjectContext *context, NSError *error);

typedef enum {
    FRSDataStoreTypeHighlights,
    FRSDataStoreTypeStories
} FRSDataStoreType;

typedef enum {
    FRSManagedObjectTypeArticle,
    FRSManagedObjectTypeUser,
    FRSManagedObjectTypeAssignment,
    FRSManagedObjectTypeStory,
    FRSManagedObjectTypeNotification,
    FRSManagedObjectTypeGallery,
    FRSManagedObjectTypePost,
    FRSManagedObjectTypeUnrecognized
} FRSManagedObjectType;

@interface FRSPersistence : NSObject
{
    
}

// galleries / stories
// highlights
-(NSArray *)pullCacheWithType:(FRSDataStoreType)dataType completion:(FRSCachePullCompletionBlock)completion;
-(NSArray *)pushCacheWithType:(FRSDataStoreType)dataType objects:(NSArray *)managedObjects completion:(FRSCachePutCompletionBlock)completion;
@end
