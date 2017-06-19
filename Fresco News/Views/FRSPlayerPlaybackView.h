//
//  FRSPlayerPlaybackView.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSPlayer;

@interface FRSPlayerPlaybackView : UIView

@property (nonatomic, strong) FRSPlayer* player;

- (void)setPlayer:(FRSPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
