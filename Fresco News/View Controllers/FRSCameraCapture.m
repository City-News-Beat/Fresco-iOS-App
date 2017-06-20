//
//  FRSCameraCapture.m
//  Fresco
//
//  Created by Omar Elfanek on 5/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCameraCapture.h"
#import "CLLocation+EXIFGPS.h"

@interface FRSCameraCapture();

@property BOOL isCapturing;

@end

@implementation FRSCameraCapture

- (instancetype)initWithDelegate:(id)delegate{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)captureStillImageWithSessionManager:(FRSAVSessionManager *)sessionManager completion:(FRSAPIDefaultCompletionBlock)completion {
    
    dispatch_async(sessionManager.sessionQueue, ^{
        
        if (self.isCapturing)
            return;
        else {
            self.isCapturing = YES;
        }
        
        AVCaptureConnection *connection = [sessionManager.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];

        [self.delegate didCaptureStillImage];
        
        
        [sessionManager.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                                          completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                                              
                                                                              CMSampleBufferRef copy = NULL;
                                                                              CMSampleBufferCreateCopy(NULL, imageDataSampleBuffer, &copy);
                                                                              
                                                                              if (copy) {
                                                                                  
                                                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
                                                                                      NSData *imageNSData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:copy];
                                                                                      
                                                                                      if (imageNSData) {
                                                                                          
                                                                                          CGImageSourceRef imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageNSData, NULL);
                                                                                          
                                                                                          //make the metadata dictionary mutable so we can add properties to it
                                                                                          NSMutableDictionary *metadata = [(__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL) mutableCopy];
                                                                                          
                                                                                          NSMutableDictionary *GPSDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
                                                                                          
                                                                                          if (!GPSDictionary)
                                                                                              GPSDictionary = [[[FRSLocator sharedLocator].currentLocation EXIFMetadata] mutableCopy];
                                                                                          
                                                                                          //Add the modified Data back into the image’s metadata
                                                                                          if (GPSDictionary) {
                                                                                              [metadata setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
                                                                                          }
                                                                                          
                                                                                          [metadata setObject:@"photo" forKey:@"capture_mode"];

                                                                                          CFStringRef UTI = CGImageSourceGetType(imgSource); //this is the type of image (e.g., public.jpeg)
                                                                                          
                                                                                          //this will be the data CGImageDestinationRef will write into
                                                                                          NSMutableData *newImageData = [NSMutableData data];
                                                                                          
                                                                                          CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1, NULL);
                                                                                          
                                                                                          if (!destination)
                                                                                              DDLogError(@"Could not create image destination");
                                                                                          
                                                                                          //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
                                                                                          CGImageDestinationAddImageFromSource(destination, imgSource, 0, (__bridge CFDictionaryRef)metadata);
                                                                                          
                                                                                          //tell the destination to write the image data and metadata into our data object.
                                                                                          //It will return false if something goes wrong
                                                                                          BOOL success = NO;
                                                                                          success = CGImageDestinationFinalize(destination);
                                                                                          
                                                                                          if (!success) {
                                                                                              DDLogError(@"Could not create data from image destination");
                                                                                              completion(nil, error);
                                                                                              self.isCapturing = NO;
                                                                                              
                                                                                              return;
                                                                                          }
                                                                                          
                                                                                          [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                                                                              
                                                                                              if (status == PHAuthorizationStatusAuthorized) {
                                                                                                  
                                                                                                  // Note that creating an asset from a UIImage discards the metadata.
                                                                                                  // In iOS 9, we can use -[PHAssetCreationRequest addResourceWithType:data:options].
                                                                                                  // In iOS 8, we save the image to a temporary file and use +[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:].
                                                                                                  if ([PHAssetCreationRequest class]) {
                                                                                                      
                                                                                                      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                                                                                          
                                                                                                          [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:newImageData options:nil];
                                                                                                          
                                                                                                      }
                                                                                                                                        completionHandler:^(BOOL success, NSError *error) {
                                                                                                                                            
                                                                                                                                            if (!success) {
                                                                                                                                                DDLogError(@"Error occurred while saving image to photo library: %@", error);
                                                                                                                                                self.isCapturing = NO;
                                                                                                                                                completion(nil, error);
                                                                                                                                            } else {
                                                                                                                                                self.isCapturing = NO;
                                                                                                                                                completion(newImageData, error);
                                                                                                                                            }
                                                                                                                                        }];
                                                                                                  } else {
                                                                                                      
                                                                                                      NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
                                                                                                      NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                                                                                                      
                                                                                                      NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
                                                                                                      
                                                                                                      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                                                                                          
                                                                                                          NSError *error = nil;
                                                                                                          
                                                                                                          [newImageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                                                                                                          
                                                                                                          if (error) {
                                                                                                              DDLogError(@"Error occured while writing image data to a temporary file: %@", error);
                                                                                                              completion(nil, error);
                                                                                                          } else {
                                                                                                              [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
                                                                                                          }
                                                                                                          
                                                                                                      }
                                                                                                                                        completionHandler:^(BOOL success, NSError *error) {
                                                                                                                                            
                                                                                                                                            if (!success) {
                                                                                                                                                DDLogError(@"Error occurred while saving image to photo library: %@", error);
                                                                                                                                                completion(nil, error);
                                                                                                                                            } else {
                                                                                                                                                completion(newImageData, error);
                                                                                                                                            }
                                                                                                                                            
                                                                                                                                            self.isCapturing = NO;
                                                                                                                                            
                                                                                                                                            // Delete the temporary file.
                                                                                                                                            [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
                                                                                                                                            
                                                                                                                                        }];
                                                                                                  }
                                                                                              }
                                                                                          }];
                                                                                      } else {
                                                                                          DDLogError(@"Could not capture still image: %@", error);
                                                                                          completion(NO, nil);
                                                                                      }
                                                                                  });
                                                                              } else {
                                                                                  DDLogError(@"Could not capture still image: %@", error);
                                                                                  completion(NO, nil);
                                                                              }
                                                                          }];
    });
}

@end
