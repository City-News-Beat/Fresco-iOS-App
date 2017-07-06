//
//  FRSTableViewSectionHeaderView.h
//  Fresco
//
//  Created by Omar Elfanek on 6/28/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSTableViewSectionHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

- (void)startLoading;
- (void)stopLoading;

@end
