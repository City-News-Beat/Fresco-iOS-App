//
//  PHAsset+Tagging.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "PHAsset+Tagging.h"
#import <objc/runtime.h>

NSString * const kFrescoFileTagPropertyKey = @"kFrescoFileTagPropertyKey";

@implementation PHAsset (Tagging)

- (void)setFileTag:(FRSFileTag *)fileTag
{
    objc_setAssociatedObject(self, (__bridge const void *)(kFrescoFileTagPropertyKey), fileTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (FRSFileTag *)fileTag
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kFrescoFileTagPropertyKey));
}

@end

