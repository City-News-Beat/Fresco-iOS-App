//
//  Fresco.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h" // Network
#import "FRSPersistence.h" // Local storage

/*
    API
 */

// api - constants
static NSString * const baseURL = @"https://api.fresconews.com/v1/";
static NSString * const stagingURL = @"https://staging.api.fresconews.com/v1/";
static NSString * const developmentURL = @"https://dev.api.fresconews.com/v1/";
static NSString * const storiesEndpoint = @"story/recent";
static NSString * const highlightsEndpoint = @"gallery/highlights";
static NSString * const assignmentsEndpoint = @"assignment/find";

// user - data
static NSInteger const maxUsernameChars = 20;
static NSInteger const maxNameChars = 40;
static NSInteger const maxLocationChars = 40;
static NSInteger const maxBioChars = 160;
static NSString * const validUsernameChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";



// map
static float const maxRadius = 50.0; // miles

//gallery
static NSInteger const maxDescriptionChars = 1500;
static NSInteger const maxGalleryItems = 10;
static float const maxVideoDuration = 60.0;

// story
static NSInteger const maxStoryTitleChar = 60;
static NSInteger const maxStoryDescriptionChar = 1500;

// social
static NSInteger const maxCommentChar = 200;


/* 
    UI
 */

static NSString * const loadingCellIdentifier = @"LoadingMoreCell";

// callbacks / blocks
typedef void (^ShareSheetBlock)(NSArray *sharedContent);
typedef void (^TransferProgressBlock)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^TransferCompletionBlock)(NSString *fileName, NSString *eTag, NSError *error, id task);
typedef void (^TransferCancellationBlock)(BOOL success, NSError *error, id task);
typedef void (^TransferPercentage)(float percentage);

