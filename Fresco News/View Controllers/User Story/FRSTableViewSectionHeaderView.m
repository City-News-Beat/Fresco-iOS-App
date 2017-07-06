//
//  FRSTableViewSectionHeaderView.m
//  Fresco
//
//  Created by Omar Elfanek on 6/28/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTableViewSectionHeaderView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"

@interface FRSTableViewSectionHeaderView ()
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet DGElasticPullToRefreshLoadingView *spinner;
@end

@implementation FRSTableViewSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [super initWithFrame:frame];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.titleLabel.text = [title uppercaseString];
    }
    
    return self;
}

- (void)startLoading {
    self.spinner.tintColor = [UIColor frescoOrangeColor];
    [self.spinner setPullProgress:90];
    [self.spinner startAnimating];
    self.spinner.alpha = 1;
}

- (void)stopLoading {
    [self.spinner stopLoading];
    self.spinner.alpha = 0;
}
@end
