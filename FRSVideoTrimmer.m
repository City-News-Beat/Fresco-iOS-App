//
//  FRSVideoTrimmer.m
//  fresco
//
//  Created by Philip Bernstein on 3/1/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSVideoTrimmer.h"

@implementation FRSVideoTrimmer

#pragma mark Main Functionality
// default method (all trims are performed here eventually)
-(void)trimAsset:(AVAsset *)asset startTime:(CMTime)startTime endTime:(CMTime)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion {
    
    NSURL *originalURL = [self urlFromAsset:asset]; // for use w/ callback
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    NSError *fileRemovalError;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&fileRemovalError];
    
    if (fileRemovalError) {
        completion(originalURL, url, fileRemovalError);
    }
    
    exportSession.outputURL = url;
    exportSession.shouldOptimizeForNetworkUse = TRUE; // leaving this on for AWS (if passed to elastic transcoder, will speed things up, MOV atom in front)
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    CMTimeRange desiredTrim = CMTimeRangeMake(startTime, CMTimeSubtract(endTime, startTime));
    exportSession.timeRange = desiredTrim;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
         completion(originalURL, url, exportSession.error); // don't need to cycle through statuses, pass through with callback
     }];
}

// fetches URL from asset if it happens to be an AVURLAsset (most of the time it is, except when drawn from PHAsset. I maintain my stance that <Photos> is worse than <Assets>)
-(NSURL *)urlFromAsset:(id)asset {
    
    if ([[asset class] isSubclassOfClass:[AVURLAsset class]]) { // we can get URL from this asset
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        return urlAsset.URL;
    }
    
    return Nil;
}

#pragma mark Lazy / Convenience Methods

// convenience methods
-(void)trimAsset:(AVAsset *)asset startSeconds:(float)startTime endSeconds:(float)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion // for use with float time values
{
    CMTime startCMTime = CMTimeMakeWithSeconds(startTime, 1.0);
    CMTime endCMTime = CMTimeMakeWithSeconds(endTime, 1.0);
    
    [self trimAsset:asset startTime:startCMTime endTime:endCMTime toURL:url withCallback:completion];
}

-(void)trimPHAsset:(PHAsset *)asset startTime:(CMTime)startTime endTime:(CMTime)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion // for use with PHAsset
{
    
    // sorry we can only trim videos....
    if (asset.mediaType != PHAssetMediaTypeVideo) {
        completion(Nil, url, [NSError errorWithDomain:@"com.fresco.phresco" code:501 userInfo:@{@"message":@"not a video dummy"}]);
        return;
    }
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:Nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [self trimAsset:asset startTime:startTime endTime:endTime toURL:url withCallback:completion];
    }];
}

-(void)trimPHAsset:(PHAsset *)asset startSeconds:(float)startTime endSeconds:(float)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion // for use with PHAsset AND float time values
{
    CMTime startCMTime = CMTimeMakeWithSeconds(startTime, 1.0);
    CMTime endCMTime = CMTimeMakeWithSeconds(endTime, 1.0);
    
    [self trimPHAsset:asset startTime:startCMTime endTime:endCMTime toURL:url withCallback:completion];
}

-(void)trimAssetAtURL:(NSURL *)startURL startTime:(CMTime)startTime endTime:(CMTime)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion // for use with a URL
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:startURL];
    [self trimAsset:asset startTime:startTime endTime:endTime toURL:url withCallback:completion];
}

-(void)trimAssetAtURL:(NSURL *)startURL startSeconds:(float)startTime endSeconds:(float)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion // for use with a URL AND float time values
{
    CMTime startCMTime = CMTimeMakeWithSeconds(startTime, 1.0);
    CMTime endCMTime = CMTimeMakeWithSeconds(endTime, 1.0);
    
    [self trimAssetAtURL:startURL startTime:startCMTime endTime:endCMTime toURL:url withCallback:completion];
}

-(UIView *)previewImagesForAsset:(AVAsset *)asset {
    return Nil;
}

@end
