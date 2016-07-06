//
//  FRSNavigationBar.m
//  Fresco
//
//  Created by Philip Bernstein on 6/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSNavigationBar.h"

@implementation FRSNavigationBar

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadStatus:)
                                                 name:FRSUploadNotification
                                               object:nil];
    
    _progressBar = [[UIView alloc] init];
    _progressBar.frame = CGRectMake(0, self.frame.size.height-2, 0, 2);
    _progressBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:_progressBar];
}

-(void)uploadStatus:(NSNotification *)notification {
    
}
@end
