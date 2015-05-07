//
//  FRSPost.h
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>
#import "MTLModel+Additions.h"

@class FRSUser, FRSTag, FRSImage;

@interface FRSPost : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *postID;
@property (nonatomic, strong, readonly) FRSUser *user;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSURL *mediaURL;
@property (nonatomic, assign) CGSize mediaSize;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *byline;
@property (nonatomic, copy, readonly) NSNumber *visibility;

- (NSURL *)largeImageURL;

@end

/*
{
_id: "55284f3b11fe08b11f00d30c",
owner: {},
byline: "George Jenkin via Fresco News",
source: "https://twitter.com/jenkin_george/status/585802954994749440",
type: "image",
file: "http://www.fresconews.com/uploads/408/large_353e51460b4944f0b70cb1b7e001897085febc38.jpg",
meta: [ ],
license: "Twitter",
location: {
type: "Point",
coordinates: [
              -1.721871,
              52.451649
              ]
},
time_created: 1428502262,
visibility: 1,
uses: [ ]
}*/