//
//  WKImagePath.h
//  Fresco
//
//  Created by Elmir Kouliev on 9/8/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    SmallImageSize,
    MediumImageSize,
    LargeImageSize
} ImageSize;

@interface WKImagePath : NSURL

+ (NSURL *)CDNImageURL:(NSString *)url withSize:(ImageSize)size;

@end
