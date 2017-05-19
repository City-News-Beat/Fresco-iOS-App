//
//  FRSFileSourcePickerViewModel.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileSourcePickerViewModel.h"

@implementation FRSFileSourcePickerViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedImage = [UIImage imageNamed:@"check-box-circle-filled"];
        self.unSelectedImage = [UIImage imageNamed:@"check-box-circle-outline"];
        
//        self.selectedTitleFont = [UIFont ];
    }
    return self;
}

@end
