//
//  FRSPersistence.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^FRSCachePutCompletionBlock)(NSManagedObject *managedObject, NSManagedObjectContext *context, NSError *error);
typedef void(^FRSCachePullCompletionBlock)(NSArray *results, NSManagedObjectContext *context, NSError *error);

@interface FRSPersistence : NSObject
{
    
}
@end
