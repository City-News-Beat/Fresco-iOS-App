//
//  FRSTipsSupportFooterView.h
//  Fresco
//
//  Created by Omar Elfanek on 5/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FRSTipsSupportFooterViewDelegate <NSObject>

- (void)presentSmooch;

@end



@interface FRSTipsSupportFooterView : UIView

- (instancetype)initWithDelegate:(id)delegate;

@property (weak, nonatomic) NSObject<FRSTipsSupportFooterViewDelegate> *delegate;

@end
