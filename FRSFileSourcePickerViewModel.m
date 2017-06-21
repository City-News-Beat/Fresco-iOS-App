//
//  FRSFileSourcePickerViewModel.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileSourcePickerViewModel.h"

@implementation FRSFileSourcePickerViewModel

- (void)commonInit {
    self.selectedImage = [UIImage imageNamed:@"check-box-circle-filled"];
    self.unSelectedImage = [UIImage imageNamed:@"check-box-circle-outline"];
    self.selectedTitleFont = [UIFont boldSystemFontOfSize:15.0];
    self.unSelectedTitleFont = [UIFont systemFontOfSize:15.0];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        [self commonInit];
        self.name = name;
    }
    return self;
}

@end
