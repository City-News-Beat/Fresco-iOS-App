//
//  FRSFileSourcePickerViewModel.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSCameraConstants.h"

@interface FRSFileSourcePickerViewModel : NSObject

@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) UIImage *unSelectedImage;

@property (strong, nonatomic) UIFont *selectedTitleFont;
@property (strong, nonatomic) UIFont *unSelectedTitleFont;

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isSelected;

- (instancetype)initWithName:(NSString *)name;

@end
