//
//  FRSFileTagOptionsTableViewCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFileTagOptionsViewModel.h"

@interface FRSFileTagOptionsTableViewCell : UITableViewCell

- (void)updateWithViewModel:(FRSFileTagOptionsViewModel *)viewModel;

@end
