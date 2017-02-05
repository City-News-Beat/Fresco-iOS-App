//
//  FRSPaymentCell.m
//  Fresco
//
//  Created by Philip Bernstein on 8/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPaymentCell.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "UIColor+Fresco.h"

@interface FRSPaymentCell ()

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@end

@implementation FRSPaymentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)startSpinner {
    self.loadingView.frame = CGRectMake(0, 0, self.selectionCircle.frame.size.width, self.selectionCircle.frame.size.height);
    [self.loadingView startAnimating];
    [self.selectionCircle addSubview:self.loadingView];
}

- (void)stopSpinner {
    [self.loadingView stopLoading];
    [self.loadingView removeFromSuperview];
}

- (IBAction)deletePayment:(id)sender {
    if (_delegate) {
        [_delegate deleteButtonClicked:self.payment];
    }
}

- (void)setActive:(BOOL)active {
    self.isActive = active;

    if (active) {
        self.selectionCircle.image = [UIImage imageNamed:@"check-box-circle-filled"];
    } else {
        self.selectionCircle.image = [UIImage imageNamed:@"check-box-circle-outline"];
    }
    self.deletionButton.hidden = active;
}
@end
