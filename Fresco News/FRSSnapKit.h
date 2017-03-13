//
//  FRSSnapKit.h
//  Fresco
//
//  Created by Omar Elfanek on 2/6/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSSnapKit : NSObject



/**
 dont forget to write this pls

 @param subView <#subView description#>
 @param parentView <#parentView description#>
 @param height <#height description#>
 */
+ (void)constrainSubview:(UIView *)subView ToBottomOfParentView:(UIView *)parentView WithHeight:(CGFloat)height;

@end
