//
//  FRSComment.h
//  Fresco
//
//  Created by Philip Bernstein on 8/24/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSUser.h"

@interface FRSComment : NSObject

@property (nonatomic, weak) FRSUser *user;
@property (nonatomic, weak) NSString *comment;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSArray *entities;
@property (nonnull, strong) NSString *imageURL;
@property (nonnull, strong) NSDictionary *userDictionary;
@property (nonatomic) BOOL isDeletable;
@property (nonatomic) BOOL isReportable;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;

- (instancetype)initWithDictionary:(NSDictionary *)commentDictionary;

@end
