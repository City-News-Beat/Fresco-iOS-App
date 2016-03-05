//
//  FRSPersistence.m
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPersistence.h"

@implementation FRSPersistence

-(NSArray *)pullCacheWithType:(FRSDataStoreType)dataType completion:(FRSCachePullCompletionBlock)completion {
    return Nil;
}

-(NSArray *)pushCacheWithType:(FRSDataStoreType)dataType objects:(NSArray *)managedObjects completion:(FRSCachePutCompletionBlock)completion {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NSManagedObject *object in managedObjects) {
            
            switch ([self managedObjectTypeFromObject:object]) {
                    
            }
            
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
    
    return Nil;
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
