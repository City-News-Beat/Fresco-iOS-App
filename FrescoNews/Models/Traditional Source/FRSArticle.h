//
//  FRSTradionalSource.h
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;
#import <Mantle/Mantle.h>

@interface FRSArticle : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *outlet;
@property (nonatomic, strong) NSURL *URL;

@end
