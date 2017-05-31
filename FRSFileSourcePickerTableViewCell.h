//
//  FRSFileSourcePickerTableViewCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFileSourcePickerViewModel.h"

@interface FRSFileSourcePickerTableViewCell : UITableViewCell

- (void)updateWithViewModel:(FRSFileSourcePickerViewModel *)viewModel;

@end
