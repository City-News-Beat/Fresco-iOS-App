//
//  PHAsset+Fresco.m
//  Fresco
//
//  Created by Elmir Kouliev on 2/27/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "PHAsset+Fresco.h"
#import "NSError+Fresco.h"

@implementation PHAsset (Fresco)

- (void)fetchFileSize:(PHAssetSizeCompletionBlock)callback {
    if(self.mediaType == PHAssetMediaTypeImage) {
        [[PHImageManager defaultManager] requestImageDataForAsset:self
                                                          options:nil
                                                    resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                        float imageSize = imageData.length;
                                                        callback([@(imageSize) integerValue], Nil);
                                                    }];
    } else {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:self
                                                        options:options
                                                  resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                                                      if ([asset isKindOfClass:[AVURLAsset class]]) {
                                                          AVURLAsset *urlAsset = (AVURLAsset *)asset;
                                                          
                                                          NSNumber *size;
                                                          NSError *fetchError;
                                                          
                                                          [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:&fetchError];
                                                          callback([size integerValue], fetchError);
                                                      }
                                                  }];
    }
}

@end
