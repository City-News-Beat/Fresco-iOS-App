//
//  FRSTipsManager.m
//  Fresco
//
//  Created by Omar Elfanek on 5/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsManager.h"

@implementation FRSTipsManager

+ (instancetype)sharedInstance {
    static FRSTipsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FRSTipsManager alloc] init];
    });
    return instance;
}

- (void)fetchTipsWithCompletion:(void (^)(id videos, NSError *error))completion {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    [manager GET:@"https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyAPjRuCjGHO6Ra13Lt8niJ4IUtbSnukNHs&part=snippet&maxResults=25&playlistId=PLbYhNm7s63x_xM7r9eCYHgGLPI5Ora-rc"
      parameters:@{}
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
             completion(responseObject, nil);
         } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             completion(nil, error);
         }];
}


// TODO: Add null checks using new functions (currently pending merge)

+ (NSString *)titleFromDictionary:(NSDictionary *)dictionary {
    return dictionary[@"snippet"][@"title"];
}

+ (NSString *)subtitleFromDictionary:(NSDictionary *)dictionary {
    return dictionary[@"snippet"][@"description"];
}

+ (NSString *)thumbnailURLStringFromDictionary:(NSDictionary *)dictionary {
    return dictionary[@"snippet"][@"thumbnails"][@"medium"][@"url"];
}

+ (NSString *)videoURLStringFromDictionary:(NSDictionary *)dictionary {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.youtube://"]] ? [NSString stringWithFormat:@"vnd.youtube://watch?v=%@&list=%@", dictionary[@"snippet"][@"resourceId"][@"videoId"], dictionary[@"snippet"][@"playlistId"]] : [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@&list=%@", dictionary[@"snippet"][@"resourceId"][@"videoId"], dictionary[@"snippet"][@"playlistId"]];
}

@end
