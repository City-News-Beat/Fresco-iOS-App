//
//  FRSUploadTask.m
//  Fresco
//
//  Created by Philip Bernstein on 10/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadTask.h"

@implementation FRSUploadTask

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    
}

-(void)uploadAsset:(AVURLAsset *)asset key:(NSString *)key withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    
}

@end
