//
//  FRSFileProgressBarView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileProgressBarView.h"
#import "FRSFileTagViewManager.h"

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
    
    [self updateProgessBar];
    
    [[FRSFileTagViewManager sharedInstance] addObserver:self forKeyPath:@"packageProgressLevel" options:0 context:nil];

}

- (void)updateProgessBar {
    switch ([[FRSFileTagViewManager sharedInstance] packageProgressLevel]) {
        case FRSPackageProgressLevelOne:
        {
            self.firstBarView.backgroundColor = [UIColor frescoRedColor];
            self.secondBarView.backgroundColor = [UIColor frescoSliderGray];
            self.thirdBarView.backgroundColor = [UIColor frescoSliderGray];
        }
            break;
        case FRSPackageProgressLevelTwo:
        {
            self.firstBarView.backgroundColor = [UIColor frescoOrangeColor];
            self.secondBarView.backgroundColor = [UIColor frescoOrangeColor];
            self.thirdBarView.backgroundColor = [UIColor frescoSliderGray];
        }
            break;
        case FRSPackageProgressLevelThree:
        {
            self.firstBarView.backgroundColor = [UIColor frescoGreenColor];
            self.secondBarView.backgroundColor = [UIColor frescoGreenColor];
            self.thirdBarView.backgroundColor = [UIColor frescoGreenColor];
        }
            break;
            
        default:
        {
         //FRSPackageProgressLevelZero
            self.firstBarView.backgroundColor = [UIColor frescoSliderGray];
            self.secondBarView.backgroundColor = [UIColor frescoSliderGray];
            self.thirdBarView.backgroundColor = [UIColor frescoSliderGray];
        }
            break;
    }
}

- (void)setupView{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                  owner:self
                                                options:nil]
                    firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == [FRSFileTagViewManager sharedInstance] && [keyPath isEqualToString:@"packageProgressLevel"]) {
        [self updateProgessBar];
    }
}



- (void)dealloc {
    [[FRSFileTagViewManager sharedInstance] removeObserver:self forKeyPath:@"packageProgressLevel"];
}


@end
