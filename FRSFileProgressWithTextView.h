//
//  FRSFileProgressWithTextView.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSFileProgressWithTextView : UICollectionReusableView

/**
 Configures the UI by setting colors and formatting textviews.
 */
- (void)setupWithShowPackageGuidelinesBlock:(SimpleActionBlock)actionBlock;

@end
