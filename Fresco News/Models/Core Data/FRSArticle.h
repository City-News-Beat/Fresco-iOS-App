//
//  FRSArticle.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FRSCoreData.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSArticle : NSManagedObject<FRSManagedObject>

+(instancetype)articleWithDictionary:(NSDictionary *)dictionary;

-(void)configureWithDictionary:(NSDictionary *)dictionary;

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "FRSArticle+CoreDataProperties.h"
