//
//  FRSUpload+CoreDataProperties.h
//  Fresco
//
//  Created by Philip Bernstein on 7/21/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUpload.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSUpload (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *chunkSize;
@property (nullable, nonatomic, retain) NSNumber *completed;
@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSNumber *fileSize;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSNumber *multipart;
@property (nullable, nonatomic, retain) NSNumber *partsComplete;
@property (nullable, nonatomic, retain) NSString *resourceURL;
@property (nullable, nonatomic, retain) NSArray *etags;
@property (nullable, nonatomic, retain) NSArray *destinationURLS;

@end

/*
 
 chunkSize
 completed
 creationDate
 destinationURLS
 etags
 fileSize
 multipart
 partsComplete
 resourceURL
 startDate
 uid
 */

NS_ASSUME_NONNULL_END