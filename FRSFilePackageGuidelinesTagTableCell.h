//
//  FRSFilePackageGuidelinesTagTableCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFileTagOptionsViewModel.h"

@interface FRSFilePackageGuidelinesTagTableCell : UITableViewCell

- (void)updateWithViewModel:(FRSFileTagOptionsViewModel *)viewModel;

@end
