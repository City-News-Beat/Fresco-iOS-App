//
//  FRSNavigationBar.m
//  Fresco
//
//  Created by Philip Bernstein on 6/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSNavigationBar.h"

@implementation FRSNavigationBar

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadStatus:)
                                                     name:FRSUploadNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)uploadStatus:(NSNotification *)notification {
    
}
@end
