//
//  InterfaceController.h
//  Fresco WatchKit Extension
//
//  Created by Elmir Kouliev on 3/10/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface FRSInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceButton* highlights;

@property (weak, nonatomic) IBOutlet WKInterfaceButton* stories;

@end