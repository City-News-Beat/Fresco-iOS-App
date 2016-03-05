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

-(void)pullCacheWithType:(FRSManagedObjectType)dataType completion:(FRSCachePullCompletionBlock)completion {


}

-(void)createManagedObjectWithType:(FRSManagedObjectType)dataType properties:(NSArray *)dictionaryRepresentation completion:(FRSCachePutCompletionBlock)completion {

    __block __weak NSManagedObject *objectToReturn = Nil; // default value // unreadable
    __block __weak NSManagedObjectContext *defaultContext = Nil; // store context
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        defaultContext = localContext;
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        completion(objectToReturn, defaultContext, error);
    }];
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
@end
