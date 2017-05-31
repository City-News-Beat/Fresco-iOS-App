//
//  FRSFileTagOptionsViewModel.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagOptionsViewModel.h"

@interface FRSFileTagOptionsViewModel()

@property (readwrite, copy, nonatomic) NSString *nameText;

@end

@implementation FRSFileTagOptionsViewModel

- (instancetype)initWithFileTag:(FRSFileTag *)fileTag {
    self = [super init];
    if(self){
        self.fileTag = fileTag;
        self.nameText = fileTag.name;
        self.captureMode = fileTag.captureMode;
    }
    return self;
}

@end
