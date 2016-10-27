//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 10/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fresco.h"


@interface FRSUploadManager : NSObject
{
    int currentIndex;
}

+(id)sharedUploader;
-(void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID;
@property (nonatomic, retain) NSMutableArray *currentUploads;
@property (nonatomic, assign) int completedUploads;
@property (nonatomic, assign) int uploadsToComplete;
@property (nonatomic, retain) NSMutableArray *uploadMeta;
@end
