//
//  FRSMultipartTask.h
//  Fresco
//
//  Created by Philip Bernstein on 3/10/16.
//  Copyright © 2016 Fresco News. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSMultipartTask.h"
#import "FRSUploadTask.h"

static int const chunkSize = 5;
static int const maxConcurrentUploads = 3;
static int const megabyteDefinition = 1048576; // bytes -> mb

static int const chunkMaxFailures = 2; // resets between chunks (otherwise behaves like superclass)
static int const chunkFailWaitTime = 2; // resets between chunks (otherwise behaves like superclass)

@interface FRSMultipartTask : FRSUploadTask <NSStreamDelegate>
{
    NSInputStream *dataInputStream;
    NSMutableData *currentData;
    NSInteger openConnections;
    NSInteger dataRead;
    NSInteger totalConnections;
    BOOL needsData;
}

@property int totalParts;
@property int completedParts;
@property (nonatomic, retain) NSArray *destinationURLS;
@property (nonatomic, retain, readonly) NSMutableArray *openConnections;
-(void)createUploadFromSource:(NSURL *)asset destinations:(NSArray *)destinations progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;
@end
