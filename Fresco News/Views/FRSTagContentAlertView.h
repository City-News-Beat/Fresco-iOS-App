//
//  FRSTagContentAlertView.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/30/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSAlertView.h"
#import "FRSCameraConstants.h"
#import "FRSFileTagOptionsViewModel.h"

@protocol FRSTagContentAlertViewDelegate <NSObject>

- (void)removeSelection;

@end

@interface FRSTagContentAlertView : FRSAlertView

@property (weak, nonatomic) id<FRSTagContentAlertViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *sourceViewModelsArray;
@property (strong, nonatomic) FRSFileTagOptionsViewModel *selectedSourceViewModel;

- (instancetype)initTagContentAlertView;
- (void)showAlertWithTagViewMode:(FRSTagViewMode)tagViewMode;

@end
