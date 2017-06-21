//
//  FRSFileNumberedView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileNumberedView.h"

@interface FRSFileNumberedView ()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@end

@implementation FRSFileNumberedView

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
    self.numberLabel.backgroundColor = [UIColor frescoBlueColor];
}

- (void)setupView{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                  owner:self
                                                options:nil]
                    firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
}

#pragma mark - Updates

- (void)updateWithNumber:(NSInteger)number {
    if (number <= 0) return;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}

@end
