//
//  FRSUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 7/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadManager.h"
#import "Fresco.h"

@implementation FRSUploadManager

-(void)createTaskForAsset:(PHAsset *)asset {
    BOOL needsRestart = (_tasks.count == 0 && _currentTasks == 0);
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        // add to end
    }
    else {
        // add to beginning
    }

    if (needsRestart) {
        [self start];
    }
}

-(void)start {
    if (_tasks.count == 0) {
        return;
    }
    
    FRSUploadTask *task = [_tasks firstObject];
    [task start];
}

-(void)pause {
    
}

-(void)resume {
    
}

-(void)commonInit {
    _tasks = [[NSMutableArray alloc] init];
    _currentTasks = [[NSMutableArray alloc] init];
    weakSelf = self;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

@end
