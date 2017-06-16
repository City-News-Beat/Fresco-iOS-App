//
//  FRSMOTDAlertView.m
//  Fresco
//
//  Created by Omar Elfanek on 6/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSMOTDAlertView.h"
#import "FRSUserManager.h"

@implementation FRSMOTDAlertView

+ (void)checkAndPresentAlert {
    [[FRSUserManager sharedInstance] getMOTDWithCompletion:^(id responseObject, NSError *error) {
        
        NSString *title = @"This is a title";
        NSString *message = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
        NSString *actionTitle = @"Action";
        NSString *cancelTitle = @"Cancel";
        NSDate *createdAt = [NSDate date];
        NSDate *expiresAt = [NSDate date];
        
        // If the apps start date is earlier than the created date
        if ([(NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:startDate] compare:createdAt] == NSOrderedAscending) {
            // If the expiration date is earlier than todays date
            if ([expiresAt compare:[NSDate date]] == NSOrderedDescending) {
                
            }
        }
        
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:title.uppercaseString message:message actionTitle:cancelTitle.uppercaseString cancelTitle:actionTitle.uppercaseString cancelTitleColor:nil delegate:nil];
        
        
        
        
        
        [alert show];
    }];
}






@end
