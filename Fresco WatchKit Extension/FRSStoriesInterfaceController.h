//
//  FRSStoriesInterfaceController.h
//  Fresco
//
//  Created by Elmir Kouliev on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

@import WatchKit;
@import Foundation;

@interface FRSStoriesInterfaceController : WKInterfaceController

@property (nonatomic, strong) NSArray *stories;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *storyTable;

- (void)populateStories;

@end
