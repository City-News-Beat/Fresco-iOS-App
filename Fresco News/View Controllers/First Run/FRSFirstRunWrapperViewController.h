//
//  FRSFirstRunWrapperViewController.h
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface FRSFirstRunWrapperViewController : FRSBaseViewController

/**
 *  Updates state of view controller components to represent index of page view controller
 *
 *  @param index Index context for update
 */

- (void)updateStateWithIndex:(NSInteger)index;
    
@end
