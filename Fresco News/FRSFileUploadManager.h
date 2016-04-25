//
//  FRSFileUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSFileUploadManager : NSObject
{
    
}
-(void)uploadPhoto:(NSData *)photoData toURL:(NSURL *)destinationURL;
-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL;
@end
