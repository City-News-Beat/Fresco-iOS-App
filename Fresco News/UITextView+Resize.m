//
//  UITextView+Resize.m
//  Fresco
//
//  Created by Philip Bernstein on 3/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "UITextView+Resize.h"


@implementation UITextView (Resize)

-(void)frs_setTextWithResize:(NSString *)text {
    self.text = text;
     NSInteger newHeight = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size.height;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
}

@end
