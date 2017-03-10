//
//  FRSPostTracker.m
//  Fresco
//
//  Created by Omar Elfanek on 2/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSPostTracker.h"

@implementation FRSPostTracker

#pragma mark - Tracking
// Temp location, move to FRSPostTracker when complete

- (void)trackPost:(FRSPost *)post parentGallery:(FRSGallery *)gallery inList:(BOOL)inList duration:(CGFloat)duration didUnmute:(BOOL)didUnmute previousPost:(FRSPost *)previousPost {
    
    
    BOOL isVideo = (post.videoUrl.length > 0) ? YES : NO;
    
    
    // Make these strings constants
    NSMutableDictionary *trackedParams = [[NSMutableDictionary alloc] initWithDictionary: @{@"post_id" : post.uid,
                                                                                            @"post_id_swiped_from" : @"",
                                                                                            @"gallery_id" : gallery.uid,
                                                                                            @"in_list" : @(inList),
                                                                                            @"duration" : @(duration),
                                                                                            @"video" : @(isVideo),
                                                                                            @"video_duration" : @"", // duration is on post
                                                                                            @"video_unmuted" : @(didUnmute)
                                                                                            }];
    
    if (!isVideo) {
        [trackedParams removeObjectsForKeys:@[@"video_duration", @"video_unmuted"]];
    }
    
    if (!previousPost) {
        [trackedParams removeObjectsForKeys:@[@"post_id_swiped_from"]];
    }
    
    
    [FRSTracker track:@"Post session" parameters:trackedParams];
    
    
    // questions
    // when should this get called? on l/r swipes on a gallery carousel?
        // Gallery detail start right away
        // If they stop in a scroll view and 'hover' (same logic as gallery hover event)
    // Get frame from cell, grab gallery from cell
    // what if they don't swipe but mute/unmute. still track?
    // `post_id_swiped_from` = post id?
}

@end
