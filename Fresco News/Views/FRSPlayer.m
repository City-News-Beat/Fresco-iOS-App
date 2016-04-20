//
//  FRSPlayer.m
//  Fresco
//
//  Created by Philip Bernstein on 4/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPlayer.h"

@implementation FRSPlayer

-(instancetype)initWithPlayerItem:(AVPlayerItem *)item {
    self = [super initWithPlayerItem:item];
    
    if (self) {
        [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
    
    return self;
}

-(void)replaceCurrentItemWithPlayerItem:(AVPlayerItem *)item {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [super replaceCurrentItemWithPlayerItem:item];
    [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.currentItem && [keyPath isEqualToString:@"status"]) {
        if (self.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            if (self.playWhenReady) {
                [super play];
                self.playWhenReady = FALSE;
            }
        }
    }
}

-(void)play {
    if (self.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        NSLog(@"PLAYING");
        [super play];
    }
    else {
        NSLog(@"WAITING");
        self.playWhenReady = TRUE;
    }
}

-(void)pause {
    [super pause];
}
@end
