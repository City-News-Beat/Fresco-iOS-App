//
//  FRSJSONResponseSerializer.h
//  Fresco
//
//  Created by Philip Bernstein on 4/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface FRSJSONResponseSerializer : AFJSONResponseSerializer
/*
    Simply to add response body as user info to error reporting from AFNetworking
 */
@end
