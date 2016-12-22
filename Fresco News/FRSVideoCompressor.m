//
//  FRSVideoCompressor.m
//  Fresco
//
//  Created by Philip Bernstein on 12/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSVideoCompressor.h"

@implementation FRSVideoCompressor
-(instancetype)initWithAsset:(AVAsset *)asset completion:(FRSCompressionCompletionBlock)completion {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}
-(instancetype)initWithAsset:(AVAsset *)asset preferences:(NSDictionary *)preferences completion:(FRSCompressionCompletionBlock)completion {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(NSURL *)temporaryFilePathURL {
    return Nil;
}

@end
