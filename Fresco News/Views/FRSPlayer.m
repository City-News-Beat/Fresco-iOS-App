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
    
    if (!_hasNotifs) {
        _hasNotifs = FALSE;
        self.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(restart)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self currentItem]];

    }
    if (self.playBlock) {
        self.playBlock(TRUE, self);
    }
}

-(void)restart {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self seekToTime:kCMTimeZero];
        [super play];
    });
}

-(void)pause {
    [super pause];
    
    if (self.playBlock) {
        self.playBlock(FALSE, self);
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
