//
//  FRSTradionalSource.h
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;
#import <Mantle/Mantle.h>

@interface FRSTradionalSource : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *prettyName;
@property (nonatomic, strong) NSURL *URL;

@end
