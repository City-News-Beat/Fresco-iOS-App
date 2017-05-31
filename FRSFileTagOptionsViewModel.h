//
//  FRSFileTagOptionsViewModel.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSFileTag.h"

@interface FRSFileTagOptionsViewModel : NSObject

@property (assign, nonatomic) BOOL isSelected;

@property (readonly, copy, nonatomic) NSString *nameText;
@property (assign, nonatomic) FRSCaptureMode captureMode;
@property (strong, nonatomic) FRSFileTag *fileTag;

- (instancetype)initWithFileTag:(FRSFileTag *)fileTag;
@end
