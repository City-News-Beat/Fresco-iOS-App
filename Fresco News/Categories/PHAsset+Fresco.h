//
//  PHAsset+Fresco.h
//  Fresco
//
//  Created by Elmir Kouliev on 2/27/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Photos/Photos.h>


/**
 Response block for providing the size for a PHAsset

 @param size Size in bytes
 @param error Error, if one
 */
typedef void (^PHAssetSizeCompletionBlock)(NSInteger size, NSError *error);

@interface PHAsset (Fresco)


/**
 Fetches file size, in bytes, of the PHAsset calling

 @param callback Callback responsbile for sending file size
 */
- (void)fetchFileSize:(PHAssetSizeCompletionBlock)callback;

@end
