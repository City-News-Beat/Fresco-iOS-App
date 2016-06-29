//
//  FRSOnboardThreeView.h
//  Fresco
//
//  Created by Omar Elfanek on 12/23/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSOnboardThreeView : UIView

-(instancetype)initWithOrigin:(CGPoint)origin;

-(void)animate;
-(UIImageView*)getCloud;
-(UIView*)getCloudContainer;

@end
