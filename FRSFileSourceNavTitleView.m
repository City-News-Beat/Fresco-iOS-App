//
//  FRSFileSourceNavTitleView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileSourceNavTitleView.h"

@interface FRSFileSourceNavTitleView ()

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation FRSFileSourceNavTitleView

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        // [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setupView{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                  owner:self
                                                options:nil]
                    firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
}

- (void)updateWithTitle:(NSString *)title {
    self.titleLabel.text = title.uppercaseString;
}

- (void)arrowUp:(BOOL)up {
    self.arrowImageView.image = up ? [UIImage imageNamed:@"arrow-up-white-icon"] : [UIImage imageNamed:@"arrow-down-white-icon"];
}

@end
