//
//  FirstRunSignUpViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@interface FirstRunPersonalViewController : FRSBaseViewController

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;

- (void)saveInfo;

@end
