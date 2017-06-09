//
//  FRSFileProgressBarView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileProgressBarView.h"

@interface FRSFileProgressBarView ()

@property (weak, nonatomic) IBOutlet UIView *firstBarView;
@property (weak, nonatomic) IBOutlet UIView *secondBarView;
@property (weak, nonatomic) IBOutlet UIView *thirdBarView;

@end

@implementation FRSFileProgressBarView

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.firstBarView.layer.cornerRadius = 4.0;
    self.secondBarView.layer.cornerRadius = 4.0;
    self.thirdBarView.layer.cornerRadius = 4.0;
}

- (void)setupView{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                  owner:self
                                                options:nil]
                    firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
}

@end
