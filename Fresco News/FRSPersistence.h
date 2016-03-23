//
//  FRSPersistence.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MagicalRecord/MagicalRecord.h>

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

#import "FRSCoreData.h" // expected behavior of each managed object

// dynamic class cast
#define objc_dynamic_cast(obj, cls) \
([obj isKindOfClass:(Class)objc_getClass(#cls)] ? (cls *)obj : NULL)

typedef void(^FRSCachePutCompletionBlock)(id managedObject, NSManagedObjectContext *context, NSError *error, BOOL success);
typedef void(^FRSCachePullCompletionBlock)(NSArray *results, NSManagedObjectContext *context, NSError *error, BOOL success);
typedef void(^FRSCacheModifyCompletionBlock)(NSError *error, BOOL success);
typedef void(^FRSCacheBulkPutCompletionBlock)(NSArray *managedObjects, NSManagedObjectContext *context, NSArray *errors, BOOL completeSuccess);
typedef void(^FRSCacheModifyBlock)(NSManagedObjectContext * localContext);

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
-(void)pullCacheWithType:(FRSManagedObjectType)dataType predicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)sort completion:(FRSCachePullCompletionBlock)completion;
-(void)createManagedObjectWithType:(FRSManagedObjectType)dataType properties:(NSDictionary *)dictionaryRepresentation completion:(FRSCachePutCompletionBlock)completion;
-(void)executeModification:(FRSCacheModifyBlock)modification completion:(FRSCacheModifyCompletionBlock)completion;
-(void)createManagedObjectsWithType:(FRSManagedObjectType)dataType objects:(NSArray *)objects completion:(FRSCacheBulkPutCompletionBlock)completion;

/*
    Cache top level stories, flush afterwords
 */

-(void)flushHighlightCacheSaving:(NSArray *)toSave completion:(FRSCacheModifyBlock)completion;
+(instancetype)defaultStore;

@end
