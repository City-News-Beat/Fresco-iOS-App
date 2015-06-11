//
//  FRSStoryRowController.h
//  Fresco
//
//  Created by Elmir Kouliev on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

@import Foundation;
@import WatchKit;

@interface FRSStoryRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *storyTitle;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *storyLocation;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *storyTime;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *storyImage1;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *storyImage2;

@end
