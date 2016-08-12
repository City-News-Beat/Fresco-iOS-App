//
//  FRSPlayer.m
//  Fresco
//
//  Created by Philip Bernstein on 4/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPlayer.h"

@implementation FRSPlayer

-(void)play {
    [super play];
    
    if (self.playBlock) {
        self.playBlock(TRUE, self);
    }
}

-(void)pause {
    [super pause];
    
    if (self.playBlock) {
        self.playBlock(FALSE, self);
    }
}

@end
