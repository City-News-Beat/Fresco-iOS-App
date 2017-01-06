//
//  FRSVideoCompressor.h
//  Fresco
//
//  Created by Philip Bernstein on 12/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^FRSCompressionCompletionBlock)(NSURL *filePath, NSError *error);

@interface FRSVideoCompressor : NSObject
- (instancetype)initWithAsset:(AVAsset *)asset completion:(FRSCompressionCompletionBlock)completion;
- (instancetype)initWithAsset:(AVAsset *)asset preferences:(NSDictionary *)preferences completion:(FRSCompressionCompletionBlock)completion;

@end
