//
//  NotificationController.h
//  Fresco WatchKit Extension
//
//  Created by Elmir Kouliev on 3/11/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

@import WatchKit;
@import Foundation;

@interface FRSNotificationController : WKUserNotificationInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceImage *postImage;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *postCaption;

-(void)handleNotification:(NSDictionary *)notification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler;

@end
