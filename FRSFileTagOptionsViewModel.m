//
//  FRSFileTagOptionsViewModel.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagOptionsViewModel.h"

@interface FRSFileTagOptionsViewModel()

@end

@implementation FRSFileTagOptionsViewModel

- (void)commonInit {
    self.selectedImage = [UIImage imageNamed:@"check-box-circle-filled"];
    self.unSelectedImage = [UIImage imageNamed:@"check-box-circle-outline"];
    self.selectedTitleFont = [UIFont boldSystemFontOfSize:15.0];
    self.unSelectedTitleFont = [UIFont systemFontOfSize:15.0];
}

- (instancetype)initWithFileTag:(FRSFileTag *)fileTag {
    self = [super init];
    if(self){
        self.fileTag = fileTag;
        self.nameText = fileTag.name;
        self.captureMode = fileTag.captureMode;
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

@end
