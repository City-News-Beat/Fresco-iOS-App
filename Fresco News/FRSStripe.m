//
//  FRSStripe.m
//  Fresco
//
//  Created by Philip Bernstein on 5/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStripe.h"

@implementation FRSStripe

+(STPCardParams *)creditCardWithNumber:(NSString *)number expiration:(NSArray *)expiration cvc:(NSString *)cvc {
    
    STPCardParams *cardParams = [[STPCardParams alloc] init];
    cardParams.number = number;
    cardParams.expMonth = [expiration[0] intValue];
    cardParams.expYear = [expiration[1] intValue];
    
    
    return cardParams;
}

+(STPCardParams *)creditCardWithNumber:(NSString *)number expiration:(NSArray *)expiration cvc:(NSString *)cvc firstName:(NSString *)firstName lastName:(NSString *)lastName {
    
    STPCardParams *cardParams = [FRSStripe creditCardWithNumber:number expiration:expiration cvc:cvc];
    cardParams.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    return cardParams;
}

+(void)createTokenWithCard:(STPCardParams *)params completion:(FRSStripeBlock)completion {
    [[STPAPIClient sharedClient] createTokenWithCard:params completion:^(STPToken *token, NSError *error) {
         completion(token, error);
    }];
}
@end
