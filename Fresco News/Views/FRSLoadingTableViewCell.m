//
//  FRSLoadingTableViewCell.m
//  
//
//  Created by Omar Elfanek on 4/11/16.
//
//

#import "FRSLoadingTableViewCell.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "UIColor+Fresco.h"

@interface FRSLoadingTableViewCell()

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@end

@implementation FRSLoadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    
    //temp fix for build, should be refactored
    if (IS_IPHONE_5) {
        self.loadingView.frame = CGRectMake(self.frame.size.width/2 -8, 0, 20, 20);
    } else if (IS_IPHONE_6) {
        self.loadingView.frame = CGRectMake(self.frame.size.width/2 +17, 0, 20, 20);
    } else if (IS_IPHONE_6_PLUS) {
        self.loadingView.frame = CGRectMake(self.frame.size.width/2 +34, 0, 20, 20);
    }
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self addSubview:self.loadingView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
