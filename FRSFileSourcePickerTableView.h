//
//  FRSFileSourcePickerTableView.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFileSourcePickerViewModel.h"

@interface FRSFileSourcePickerTableView : UITableView

@property (strong, nonatomic) NSMutableArray *sourceViewModelsArray;
@property (strong, nonatomic) FRSFileSourcePickerViewModel *selectedSourceViewModel;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) BOOL isExpanded;

@end
