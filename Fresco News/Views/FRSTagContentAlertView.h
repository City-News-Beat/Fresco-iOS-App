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

@interface FRSTagContentAlertView : FRSAlertView

@property (strong, nonatomic) NSMutableArray *sourceViewModelsArray;

- (instancetype)initTagContentAlertView;
- (void)showAlertWithTagViewMode:(FRSTagViewMode)tagViewMode;

@end
