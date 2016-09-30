//
//  FRSNotificationTester.m
//  Fresco
//
//  Created by Philip Bernstein on 9/30/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

/*
 
 needs.body({
 'user-news-photos-of-day_': { text: 'str', post_ids: 'int[]' },
 'user-news-today-in-news_': { text: 'str', gallery_ids: 'int[]'  }, // TODO format?
 'user-news-gallery_': { text: 'str', gallery_id: 'int' },
 'user-news-story_': { text: 'str', story_id: 'int' },
 'user-news-custom-push_': { title: 'str', body_: 'str' },
 'user-social-followed_': { other_user_ids: 'int[]' },
 'user-social-liked_': { other_user_ids: 'int[]', gallery_id: 'int' },
 'user-social-reposted_': { other_user_ids: 'int[]', gallery_id: 'int' },
 'user-social-commented_': { other_user_ids: 'int[]', comment_ids: 'int[]', gallery_id: 'int' },
 'user-dispatch-new-assignment_': { assignment_id: 'int' },
 'user-dispatch-assignment-expired_': { assignment_id: 'int' }, // NOTE only sends to accepted users
 // 'user-dispatch-purchased_': { outlet_id: 'int', post_ids: 'int[]', has_card_: 'bool' },
 'user-payment-payment-expiring_': { total: 'int', amount_: 'int' }, // NOTE providing `amount` sends impartial expire notif
 'user-payment-payment-sent_': { total: 'int' },
 'user-payment-payment-declined_': 'bool',
 // 'user-payment-tax-info-required_': { amount: 'int' }, // NOTE approaching_600 = 0-599, over_600 = 600-2999, approaching_3200 = 3000-3199, over_3200 = 3200+
 'user-payment-tax-info-processed_': 'bool',
 'user-payment-tax-info-declined_': 'bool',
 'user-promo-code-entered_': { other_user_id: 'int' },
 'user-promo-first-assignment_': { has_card_: 'bool' },
 'user-promo-recruit-fulfilled_': { other_user_id: 'int', has_card_: 'bool' }
 }),
 
 */

#import "FRSNotificationTester.h"
#import "FRSAPIClient.h"

@implementation FRSNotificationTester
+(void)createAllNotifications {
    [self createAssignmentNotification];
    [self createFollowNotification];
    [self createRepostNotification];
    [self createLikeNotification];
    [self createLikeNotification];
    [self createGalleryNotification];
    [self createStoryNotification];
    [self createMoneySentNotification];
}

+(void)createAssignmentNotification {
    NSDictionary *notification = @{@"user-dispatch-new-assignment":@{@"assignment_id":@"J6K3beMr1yGQ"}};
    [[FRSAPIClient sharedClient] post:@"user/testnotif" withParameters:notification completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
    }];
}

+(void)createFollowNotification {
    NSDictionary *notification = @{@"user-social-followed":@{@"other_user_ids":@[@"7ewm8YP3GL5x"]}};
    [[FRSAPIClient sharedClient] post:@"user/testnotif" withParameters:notification completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
    }];
}

+(void)createRepostNotification {
    NSDictionary *notification = @{@"user-social-reposted":@{@"other_user_ids":@[@"7ewm8YP3GL5x"], @"gallery_id":@"5xQ0Woz6x0lX"}};
    [[FRSAPIClient sharedClient] post:@"user/testnotif" withParameters:notification completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
    }];
}

+(void)createCommentNotification {
    NSDictionary *notification = @{@"user-social-commented":@{@"other_user_ids":@[@"7ewm8YP3GL5x"], @"gallery_id":@"5xQ0Woz6x0lX", @"comment_ids":@[@"EXVk1adr0Bwy"]}};
    [[FRSAPIClient sharedClient] post:@"user/testnotif" withParameters:notification completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
    }];
}

+(void)createLikeNotification {
    NSDictionary *notification = @{@"user-social-liked":@{@"other_user_ids":@[@"7ewm8YP3GL5x"], @"gallery_id":@"5xQ0Woz6x0lX"}};
    [[FRSAPIClient sharedClient] post:@"user/testnotif" withParameters:notification completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
    }];
}

+(void)createGalleryNotification {
    //user-news-gallery
}

+(void)createStoryNotification {
    //user-news-story
}

+(void)createMoneySentNotification {
    
}


@end
