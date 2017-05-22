//
//  FRSAssignmentManager.h
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSAssignmentManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getAssignmentsByCheckingPostsLocationWithUserLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unacceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getAcceptedAssignmentWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getAssignmentWithUID:(NSString *)assignment completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude navigationController:(UINavigationController *)navigationController;

@end
