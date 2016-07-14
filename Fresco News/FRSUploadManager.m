//
//  FRSUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 7/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadManager.h"

@implementation FRSUploadManager

-(void)createTaskForAsset:(PHAsset *)asset {
    BOOL needsRestart = (_tasks.count == 0);
    
    
    if (needsRestart) {
        [self start];
    }
    
}

-(void)start {
    
}

-(void)pause {
    
}

-(void)resume {
    
}

-(void)commonInit {
    _tasks = [[NSMutableArray alloc] init];
    _currentTasks = [[NSMutableArray alloc] init];
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

@end
