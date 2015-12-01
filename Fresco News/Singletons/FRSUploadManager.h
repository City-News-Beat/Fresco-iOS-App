//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Elmir Kouliev on 10/23/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "FRSGallery.h"
#import "FRSAssignment.h"
#import "FRSPost.h"

@protocol FRSUploadManagerDelegate <NSObject>

-(void)uploadCompleteWithCrossPostString:(NSString *)string;

@end

@interface FRSUploadManager : AFHTTPSessionManager

@property (weak, nonatomic) NSObject <FRSUploadManagerDelegate> *delegate;


/**
 *  Shared accessor for manager
 *
 *  @return Returns singleton instance of FRSUploadManager
 */

+ (FRSUploadManager *)sharedManager;

#pragma mark - Upload Methods

/**
 *  Uploads a gallery to the API
 *
 *  @param gallery       The gallery obj to upload
 *  @param assignment    Optional assignment obj to attach to gallery
 *  @param responseBlock Response block containing created gallery
 */

- (void)uploadGallery:(FRSGallery *)gallery withAssignment:(FRSAssignment *)assignment withSocialOptions:(NSDictionary *)socialOptions withResponseBlock:(FRSAPISuccessBlock)responseBlock;


/**
 *  Uploads a post to an existing gallery
 *
 *  @param post          The post to upload
 *  @param galleryId     The gallery to add to
 *  @param assignment    The assignment to attach to (optional)
 *  @param responseBlock Success block block indiciating success or failure
 */

- (void)uploadPost:(FRSPost *)post withGalleryId:(NSString *)galleryId withResponseBlock:(FRSAPISuccessBlock)responseBlock;


#pragma mark - Social Upload Methods

- (void)postToTwitter:(NSString *)string;

- (void)postToFacebook:(NSString *)string;


#pragma mark - User Defaults Management

/**
 *  Resets user default values for the uploading gallery
 */

- (void)resetDraftGalleryPost;

@end
