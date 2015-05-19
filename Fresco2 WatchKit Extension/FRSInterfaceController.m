//  InterfaceController.m
//  Fresco WatchKit Extension
//
//  Created by Elmir Kouliev on 3/10/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSInterfaceController.h"
#import "FRSGalleryRowController.h"
#import "FRSWKGalleryDetail.h"

@implementation FRSInterfaceController

- (id)init{

    if(self = [super init]) {
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

@end
