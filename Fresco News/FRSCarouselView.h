//
//  FRSCarouselView.h
//  Fresco
//
//  Created by Philip Bernstein on 3/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Haneke.h"

@interface FRSCarouselView : UIView
{
    NSMutableArray *imageViews; // reusable
    NSMutableArray *videoPlayers; // expendable
}

-(void)loadContent:(NSArray *)content;

@end
