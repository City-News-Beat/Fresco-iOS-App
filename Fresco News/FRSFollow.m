//
//  FRSFollow.m
//  Fresco
//
//  Created by Philip Bernstein on 11/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollow.h"
#import "FRSAPIClient.h"

@implementation FRSFollow
+(void)follow:(int)i {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString *url = [@"https://api.fresconews.com/codec/" stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
        [request setURL:[NSURL URLWithString:url]];
        [request setValue:@"Bearer jym6FnFFp6yesUBmZN2cEeeyNTsrug9Me4KkQX1SuNWofTW9oDITn2W8Zf4LR5tCgS8vXPd47Z5YIl7bK8q9TLaU3rsRGfjzZeajnN8BXWEw8V4sr8ny1yA6qkmMSnew0M13Nq5xhIeKi64RWClaHluMhDEYSX9u36I48jY1uBruMKeHDFBlybfi4gyrFc" forHTTPHeaderField:@"Authorization"];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        
        if([responseCode statusCode] != 200){
            NSLog(@"Error getting %@, HTTP status code %lu", url, [responseCode statusCode]);
        }
        else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:Nil];
            NSString *userID = dict[@"encode"];
            NSLog(@"FOLLOWING USER: %@", userID);

            [[FRSAPIClient sharedClient] followUserID:userID completion:^(id responseObject, NSError *error) {
                if (TRUE) {
                    NSLog(@"FOLLOWED USER: %@", userID);
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [FRSFollow follow:i+1];
                    });
                }
            }];
        }
}
@end
