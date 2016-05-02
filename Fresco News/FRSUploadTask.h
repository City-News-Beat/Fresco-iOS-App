//
//  FRSUploadTask.h
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fresco.h"
#import <Photos/Photos.h>

@interface FRSUploadTask : NSObject
{
    
}

@property TransferCompletionBlock completionBlock;
@property TransferProgressBlock progressBlock;
@property BOOL hasStarted;
-(void)beginUploadFromSource:(PHAsset *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;
@end
