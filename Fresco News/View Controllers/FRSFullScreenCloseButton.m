//
//  FRSFullScreenCloseButton.m
//  Fresco
//
//  Created by Omar Elfanek on 6/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFullScreenCloseButton.h"

@implementation FRSFullScreenCloseButton

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    }
    
    return self;
}


@end
