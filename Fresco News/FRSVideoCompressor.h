//
//  FRSVideoCompressor.h
//  Fresco
//
//  Created by Philip Bernstein on 12/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSVideoCompressor : NSObject
-(instancetype)initWithAsset:(AVAsset *)asset;
-(instancetype)initWithAsset:(AVAsset *)asset preferences:(NSDictionary *)preferences;

@end
