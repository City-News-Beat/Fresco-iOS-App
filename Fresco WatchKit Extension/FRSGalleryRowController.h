//
//  FRSPostRowCell.h
//  Fresco
//
//  Created by Fresco News on 3/11/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

@import Foundation;
@import WatchKit;

@interface FRSGalleryRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *galleryGroup;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *galleryImage;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryLocation;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *galleryTime;

@end
