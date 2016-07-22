//
//  FRSDebitCardViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "CardIO.h"

@interface FRSDebitCardViewController : FRSBaseViewController <UITextFieldDelegate,CardIOViewDelegate>
{
    UIView *cardViewport;
}
@end
