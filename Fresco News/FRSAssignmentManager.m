
//
//  FRSAssignmentManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentManager.h"

@import MapKit;

static NSString *const assignmentsEndpoint = @"assignment/find";
static NSString *const assignmentPostsCheckEndpoint = @"assignment/posts/check";
static NSString *const acceptAssignmentEndpoint = @"assignment/%@/accept";
static NSString *const unacceptAssignmentEndpoint = @"assignment/%@/unaccept";
static NSString *const acceptedAssignmentEndpoint = @"assignment/accepted";

@implementation FRSAssignmentManager

+ (instancetype)sharedInstance {
    static FRSAssignmentManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSAssignmentManager alloc] init];
    });
    return instance;
}

/*
 Fetch assignments w/in radius of user location, calls generic method w/ parameters & endpoint
 */
- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion {

    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"Point" forKey:@"type"];
    [geoData setObject:location forKey:@"coordinates"];

    NSDictionary *params = @{

        @"geo" : geoData,
        @"radius" : @(radius),
    };

    [[FRSAPIClient sharedClient] get:assignmentsEndpoint
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

/*
 Fetch assignments by checking the posts location, This will return only those assignments which are within the location points
 */
- (void)getAssignmentsByCheckingPostsLocations:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"MultiPoint" forKey:@"type"];
    [geoData setObject:location forKey:@"coordinates"];
    
    NSDictionary *params = @{
                             @"geo" : geoData,
                             };
    
    [[FRSAPIClient sharedClient] get:assignmentPostsCheckEndpoint
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                              completion(responseObject, error);
                          }];
}

- (void)getAssignmentWithUID:(NSString *)assignment completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:@"assignment/%@", assignment];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                completion(responseObject, error);
                                return;
                            }

                            if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                                completion(responseObject, error);
                            } else {
                                completion(nil, error);
                            }
                          }];
}

- (void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:acceptAssignmentEndpoint, assignmentID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)unacceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unacceptAssignmentEndpoint, assignmentID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)getAcceptedAssignmentWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:acceptedAssignmentEndpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)navigateToAssignmentWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude navigationController:(UINavigationController *)navigationController {
    UIAlertController *view = [UIAlertController
        alertControllerWithTitle:nil
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *googleMaps = [UIAlertAction
        actionWithTitle:@"Open with Google Maps"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {
                  [view dismissViewControllerAnimated:YES completion:nil];

                  //https://www.google.com/maps/dir/40.7155488,+-74.0207971/Flatiron+School,+11+Broadway+%23260,+New+York,+NY+10004/
                  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%f,%f", latitude, longitude]];
                  if (![[UIApplication sharedApplication] canOpenURL:url]) {
                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", latitude, longitude]]];
                  } else {
                      [[UIApplication sharedApplication] openURL:url];
                  }
                }];

    UIAlertAction *appleMaps = [UIAlertAction
        actionWithTitle:@"Open with Apple Maps"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {
                  [view dismissViewControllerAnimated:YES completion:nil];

                  CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(latitude, longitude);
                  MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
                  MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];

                  NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
                  [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];

                  [endingItem openInMapsWithLaunchOptions:launchOptions];
                }];

    UIAlertAction *cancel = [UIAlertAction
        actionWithTitle:@"Cancel"
                  style:UIAlertActionStyleCancel
                handler:^(UIAlertAction *action) {
                  [view dismissViewControllerAnimated:YES completion:nil];

                }];

    [view addAction:googleMaps];
    [view addAction:appleMaps];
    [view addAction:cancel];

    [navigationController presentViewController:view animated:YES completion:nil];
}

@end
