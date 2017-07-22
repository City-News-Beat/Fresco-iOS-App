//
//  FRSAssignmentDescriptionViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 7/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "FRSDispatchConstants.h"

@interface FRSAssignmentDescriptionViewController : FRSBaseViewController

@property (strong, nonatomic) NSMutableDictionary *assignment;
@property AssignmentTypes assignmentType;

+ (NSAttributedString *)formattedAttributedStringFromString:(NSString *)text;
@end
