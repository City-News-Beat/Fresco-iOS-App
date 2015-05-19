//
//  FRSGlanceInterfaceController.h
//  Fresco
//
//  Created by Elmir Kouliev on 3/31/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface FRSGlanceInterfaceController : WKInterfaceController

@property (nonatomic, strong) NSArray *posts;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *firstImage;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *secondImage;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *thirdImage;

@end
