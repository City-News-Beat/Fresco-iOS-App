//
//  FRSPersistence.m
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPersistence.h"
#include <objc/runtime.h>

#define objc_dynamic_cast(obj, cls) \
([obj isKindOfClass:(Class)objc_getClass(#cls)] ? (cls *)obj : NULL)

@implementation FRSPersistence


#pragma mark Highlight-Cache

-(void)flushHighlightCacheSaving:(NSArray *)toSave completion:(FRSCacheModifyBlock)completion {
    
    __block NSMutableArray *idsToSave = [[NSMutableArray alloc] init];
    __block NSManagedObjectContext *thisContext;
    
    for (FRSStory *story in toSave) {
        [idsToSave addObject:story.uid];
    }
    
    [self executeModification:^(NSManagedObjectContext *localContext) {
        
        thisContext = localContext;
        
        NSArray *stories = [FRSStory MR_findAll];
        
        for (FRSStory *story in stories) {
            if ([idsToSave containsObject:story.uid]) {
                // skip
            }
            else {
                // goodbye
                [story MR_deleteEntityInContext:localContext];
            }
        }

    } completion:^(NSError *error, BOOL success) {
        completion(thisContext);
    }];
}

/*
    Generic top level block that just makes us not have to work with MagicalRecord elsewhere
 */
-(void)executeModification:(FRSCacheModifyBlock)modification completion:(FRSCacheModifyCompletionBlock)completion {
    [MagicalRecord saveWithBlock:modification completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        completion(error, contextDidSave);
    }];
}

/*
    Pull from cache, need to add index, sorting, and filtering
 */

-(void)pullCacheWithType:(FRSManagedObjectType)dataType predicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)sort completion:(FRSCachePullCompletionBlock)completion {
    
    __block NSArray *pulledFromCache;
    __block NSManagedObjectContext *currentContext;
    
    [self executeModification:^(NSManagedObjectContext *localContext) {
        
        // save context for later
        currentContext = localContext;
        
        // set up fetch request
        // set type to correct type
        // add predicate to fetch request
        // add sort descriptor to fetch request
        
        // perform fetch
        // completion with results
        
        // save output to [pulledFromCache]
        // faults or no faults on returned objects?
        
    } completion:^(NSError *error, BOOL success) {
        completion(pulledFromCache, currentContext, error, success);
    }];
}


/*
    Designed specifically to create a core data entry for each object type based on its dictionary representation
 
    *note* move from MagicalRecord to [self executeModification:^(){}];
 */

-(void)createManagedObjectWithType:(FRSManagedObjectType)dataType properties:(NSDictionary *)dictionaryRepresentation completion:(FRSCachePutCompletionBlock)completion {
    
    __block __strong Class managedObjectClass= [self managedObjectClassFromType:dataType];
    __block __strong id<FRSManagedObject, NSObject> objectToReturn = Nil; // default value // unreadable
    __block __strong NSManagedObjectContext *defaultContext = Nil; // store context (weakly) for completion
    
    /* 
        No real analysis needed at this level, pass everything upward
     */
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        defaultContext = localContext;
        
        if ([managedObjectClass instancesRespondToSelector:@selector(initWithProperties:)]) { // auto setup (please)
            
            objectToReturn = [[managedObjectClass alloc] initWithProperties:dictionaryRepresentation context:localContext];
        }
        else {
            
            objectToReturn = [[managedObjectClass alloc] init]; // boring old subclass
            
            for (NSString *key in [dictionaryRepresentation allKeys]) {
                
                NSString *useableKey = [key capitalizedString];
                useableKey = [useableKey stringByReplacingOccurrencesOfString:@" " withString:@""];
                useableKey = [useableKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[useableKey substringToIndex:1]];

                if ([managedObjectClass instancesRespondToSelector:NSSelectorFromString(useableKey)]) {
                    
                    id valueForKey = [dictionaryRepresentation objectForKey:key];
                    
                    if (valueForKey && [managedObjectClass instancesRespondToSelector:NSSelectorFromString(useableKey)]) {
                        [objectToReturn performSelector:@selector(setValue:forKey:) withObject:useableKey withObject:valueForKey];
                    }
                }
            }
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        completion(objectToReturn, defaultContext, error, contextDidSave);
        
        // reference count
        objectToReturn = Nil;
        managedObjectClass = Nil;
        defaultContext = Nil;
    }];
}

/*
    Bulk object creation
 */


-(void)createManagedObjectsWithType:(FRSManagedObjectType)dataType objects:(NSArray *)objects completion:(FRSCacheBulkPutCompletionBlock)completion {
    
    __block NSInteger toComplete = [objects count];
    __block NSInteger completed = 0;
    
    __block NSMutableArray *completedManagedObjects = [[NSMutableArray alloc] init];
    __block NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    for (NSDictionary *properties in objects) {
        [self createManagedObjectWithType:dataType properties:properties completion:^(id managedObject, NSManagedObjectContext *context, NSError *error, BOOL success) {
            
            if (!success || error) {
                [errors addObject:error];
            }
            
            if (managedObject) {
                [completedManagedObjects addObject:managedObject];
            }
            
            completed++;
            
            if (toComplete == completed) {
                completion(completedManagedObjects, context, errors, ([errors count] == 0));
            }
        }];
    }
}
                   
-(Class)managedObjectClassFromType:(FRSManagedObjectType)objectType {
    
    switch (objectType) {
        case FRSManagedObjectTypeUser:
            return [FRSUser class];
            break;
        case FRSManagedObjectTypePost:
            return [FRSPost class];
            break;
        case FRSManagedObjectTypeStory:
            return [FRSStory class];
            break;
        case FRSManagedObjectTypeGallery:
            return [FRSGallery class];
            break;
        case FRSManagedObjectTypeNotification:
            return [FRSNotification class];
            break;
        case FRSManagedObjectTypeAssignment:
            return [FRSAssignment class];
            break;
        case FRSManagedObjectTypeUnrecognized:
            return [NSManagedObject class];
            break;
        default:
            return [NSManagedObject class];
            break;
    }
    
    return [NSManagedObject class];
}

-(FRSManagedObjectType)managedObjectTypeFromObject:(id)object {
    
    if ([[object class] isSubclassOfClass:[FRSArticle class]]) {
        return FRSManagedObjectTypeArticle;
    }
    else if ([[object class] isSubclassOfClass:[FRSUser class]]) {
        return FRSManagedObjectTypeUser;
    }
    else if ([[object class] isSubclassOfClass:[FRSAssignment class]]) {
        return FRSManagedObjectTypeAssignment;
    }
    else if ([[object class] isSubclassOfClass:[FRSStory class]]) {
        return FRSManagedObjectTypeStory;
    }
    else if ([[object class] isSubclassOfClass:[FRSNotification class]]) {
        return FRSManagedObjectTypeNotification;
    }
    else if ([[object class] isSubclassOfClass:[FRSGallery class]]) {
        return FRSManagedObjectTypeGallery;
    }
    else if ([[object class] isSubclassOfClass:[FRSPost class]]) {
        return FRSManagedObjectTypePost;
    }
    
    return FRSManagedObjectTypeUnrecognized;
}

/*
 Singleton
 */

+(instancetype)defaultStore {
    static FRSPersistence *persistence = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        persistence = [[FRSPersistence alloc] init];
    });
    
    return persistence;
}
@end
