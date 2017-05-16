//
//  FRSTipsManager.h
//  Fresco
//
//  Created by Omar Elfanek on 5/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSTipsManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)fetchTipsWithCompletion:(void (^)(id videos, NSError *error))completion;

+ (NSString *)titleFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)subtitleFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)thumbnailURLStringFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)videoURLStringFromDictionary:(NSDictionary *)dictionary;

@end
