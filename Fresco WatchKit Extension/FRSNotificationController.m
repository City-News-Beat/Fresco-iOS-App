//
//  NotificationController.m
//  Fresco WatchKit Extension
//
//  Created by Fresco News on 3/11/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

@import UIKit;

#import "FRSNotificationController.h"

@implementation FRSNotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
 
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    
    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    
    [self handleNotification:[localNotification userInfo] withCompletion:completionHandler];
    


}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    
    //     This method is called when a remote notification needs to be presented.
    //     Implement it if you use a dynamic notification interface.
    //     Populate your dynamic notification interface as quickly as possible.
    //

    [self handleNotification:remoteNotification withCompletion:completionHandler];
    
}

-(void)handleNotification:(NSDictionary *)notification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler{
    
    [self.postImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:notification[@"image"]]]];
    
    [self.postCaption setText:notification[@"aps"][@"alert"][@"body"]];
    
    completionHandler(WKUserNotificationInterfaceTypeCustom);

}


@end



