//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 7/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "FRSMultipartTask.h"

@interface FRSUploadManager : NSObject
{
    
}
@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic, retain) NSMutableArray *currentTasks;
-(void)createTaskForAsset:(PHAsset *)asset;
-(void)start;
-(void)pause;
-(void)resume;
@end
