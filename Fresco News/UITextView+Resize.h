//
//  UITextView+Resize.h
//  Fresco
//
//  Created by Philip Bernstein on 3/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UITextView (Resize)
-(void)frs_setTextWithResize:(NSString *)text;
-(void)frs_resize;
@end
