//
//  FRSTip.h
//  Fresco
//
//  Created by Omar Elfanek on 5/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
//  An FRSTip object to be used when creating cells in the tips tableView.


#import <Foundation/Foundation.h>
#import "FRSTipsManager.h"

@interface FRSTip : NSObject


/**
 Creates an FRSTip object from the given dictionary.

 @param dictionary NSDictionary with a videoURL, thumbnailURL, title, and subtitle.
 @return FRSTip
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (strong, nonatomic) NSString *videoURL;
@property (strong, nonatomic) NSString *thumbnailURL;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;

@end
