//
//  FRSSearchViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface FRSSearchViewController : FRSBaseViewController<UITextFieldDelegate>
{
    BOOL isInDefault;
}
@property (nonatomic, retain) NSArray *representedData;
@property (nonatomic, retain) NSArray *defaultData;
@end
