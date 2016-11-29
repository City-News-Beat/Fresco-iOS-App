//
//  FRSUserAnnotation.m
//  Fresco
//
//  Created by Omar Elfanek on 7/26/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserAnnotation.h"
#import <Foundation/Foundation.h>

@implementation FRSUserAnnotation

-(instancetype)init {
   self = [super init];
    
    if (self) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        view.backgroundColor = [UIColor redColor];
        
    }
    return self;
}

@end
