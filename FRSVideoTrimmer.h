//
//  FRSVideoTrimmer.h
//  fresco
//
//  Created by Philip Bernstein on 3/1/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

/*
    Comprehensive video trimmer, can handle pretty much anything thrown at it. Output is a standard quicktime container. Added some lazy helper methods that convert various inputs into AVAsset & CMTime for default trim call
 
    Should be very quick -- as long as the output is not enormous (for use in the context of this, it would be 1 minute or less, can't imagine that taking more than 2 seconds in most cases)
 
 */

typedef void (^TrimCompletion)(NSURL *originalURL, NSURL *destinationURL, NSError *error);

@interface FRSVideoTrimmer : NSObject
{
    
}

// base method
-(void)trimAsset:(AVAsset *)asset startTime:(CMTime)startTime endTime:(CMTime)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion;

// convenience methods
-(void)trimAsset:(AVAsset *)asset startSeconds:(float)startTime endSeconds:(float)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion; // for use with float time values

-(void)trimPHAsset:(PHAsset *)asset startTime:(CMTime)startTime endTime:(CMTime)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion; // for use with PHAsset

-(void)trimPHAsset:(PHAsset *)asset startSeconds:(float)startTime endSeconds:(float)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion; // for use with PHAsset AND float time values

-(void)trimAssetAtURL:(NSURL *)startURL startTime:(CMTime)startTime endTime:(CMTime)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion; // for use with a URL

-(void)trimAssetAtURL:(NSURL *)startURL startSeconds:(float)startTime endSeconds:(float)endTime toURL:(NSURL *)url withCallback:(TrimCompletion)completion; // for use with a URL AND float time values

-(UIView *)previewImagesForAsset:(AVAsset *)asset;

@end
