//
//  FRSLikeRepostViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 4/17/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSLikeRepostViewController.h"
#import "FRSGalleryManager.h"

@interface FRSLikeRepostViewController ()
@property (strong, nonatomic) NSString *galleryID;

@end

@implementation FRSLikeRepostViewController
int const FETCH_LIMIT = 20;

- (instancetype)initWithGallery:(NSString *)galleryID {
    self = [super init];
    
    if (self) {
        self.galleryID = galleryID;
        self.leftTitle = @"LIKES";
        self.rightTitle = @"REPOSTS";
    }
    
    return self;
}

#pragma mark - Datasource

- (void)fetchLeftDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSGalleryManager sharedInstance] fetchLikesForGallery:self.galleryID
                                                       limit:[NSNumber numberWithInteger:FETCH_LIMIT]
                                                      lastID:@""
                                                  completion:completion];
}

- (void)fetchRightDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSGalleryManager sharedInstance] fetchRepostsForGallery:self.galleryID
                                                         limit:[NSNumber numberWithInteger:FETCH_LIMIT]
                                                        lastID:@""
                                                    completion:completion];
}

- (void)loadMoreLeftUsersFromLast:(NSString *)last withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSGalleryManager sharedInstance] fetchRepostsForGallery:self.galleryID
                                                         limit:[NSNumber numberWithInteger:FETCH_LIMIT]
                                                        lastID:last
                                                    completion:completion];
}

-(void)loadMoreRightUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSGalleryManager sharedInstance] fetchRepostsForGallery:self.galleryID
                                                         limit:[NSNumber numberWithInteger:FETCH_LIMIT]
                                                        lastID:lastUserID
                                                    completion:completion];
}

@end
