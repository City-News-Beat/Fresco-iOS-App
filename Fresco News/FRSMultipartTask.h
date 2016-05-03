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


#define MB 1024*1024
#define MAX_CONCURRENT 3
#define CHUNK_SIZE 5

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

-(void)pause;
-(void)resume;

@end
