//
//  FRSFileSourceNavTitleView.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSFileSourceNavTitleView : UIView
@property(nonatomic,weak) IBOutlet UIButton *actionButton;

- (void)updateWithTitle:(NSString *)title;
- (void)arrowUp:(BOOL)up;

@end
