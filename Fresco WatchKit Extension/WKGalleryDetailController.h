//
//  FRSWatchPostDetail.h
//  Fresco
//
//  Created by Fresco News on 3/16/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

@import WatchKit;
@import Foundation;

@interface WKGalleryDetailController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryLocation;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryTime;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryCaption;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryByline;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *galleryImages;

@property (strong, nonatomic) NSDictionary *gallery;

@end
