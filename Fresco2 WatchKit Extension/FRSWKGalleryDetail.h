//
//  FRSWatchPostDetail.h
//  Fresco
//
//  Created by Elmir Kouliev on 3/16/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface FRSWKGalleryDetail : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryLocation;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryTime;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryCaption;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryByline;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *galleryImage;

@property (strong, nonatomic) NSDictionary *post;


@end