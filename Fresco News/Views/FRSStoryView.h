//
//  FRSStoryView.h
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fresco.h"

@class FRSStory;

@protocol FRSStoryViewDelegate <NSObject>

-(BOOL)shouldHaveActionBar;
-(BOOL)shouldHaveTextLimit;

@end

@interface FRSStoryView : UIView

@property (weak, nonatomic) NSObject <FRSStoryViewDelegate> *delegate;
@property (weak, nonatomic) ActionButtonBlock actionBlock;
@property (strong, nonatomic) FRSStory *story;


-(instancetype)initWithFrame:(CGRect)frame story:(FRSStory *)story delegate:(id <FRSStoryViewDelegate>)delegate;

@end
