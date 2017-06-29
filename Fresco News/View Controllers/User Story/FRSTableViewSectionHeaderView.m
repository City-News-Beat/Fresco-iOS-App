//
//  FRSTableViewSectionHeaderView.m
//  Fresco
//
//  Created by Omar Elfanek on 6/28/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTableViewSectionHeaderView.h"

@interface FRSTableViewSectionHeaderView ()
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;

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

@end
