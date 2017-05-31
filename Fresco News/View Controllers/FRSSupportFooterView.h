//
//  FRSSupportFooterView.h
//  Fresco
//
//  Created by Omar Elfanek on 5/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FRSSupportFooterViewDelegate <NSObject>

- (void)presentSmooch;

@end



@interface FRSSupportFooterView : UIView

- (instancetype)initWithDelegate:(id)delegate;

@property (weak, nonatomic) NSObject<FRSSupportFooterViewDelegate> *delegate;

@end
