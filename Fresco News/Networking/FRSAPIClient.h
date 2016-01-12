//
//  FRSAPIClient.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);

@interface FRSAPIClient : NSObject


-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;


@end
