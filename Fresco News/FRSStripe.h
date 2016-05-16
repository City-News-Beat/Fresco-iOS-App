//
//  FRSStripe.h
//  Fresco
//
//  Created by Philip Bernstein on 5/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Stripe/Stripe.h>

typedef void(^FRSStripeBlock)(STPToken *stripeToken, NSError *error);

@interface FRSStripe : NSObject
+(STPCardParams *)creditCardWithNumber:(NSString *)number expiration:(NSArray *)expiration cvc:(NSString *)cvc;
+(STPCardParams *)creditCardWithNumber:(NSString *)number expiration:(NSArray *)expiration cvc:(NSString *)cvc firstName:(NSString *)firstName lastName:(NSString *)lastName;

+(void)createTokenWithCard:(STPCardParams *)params completion:(FRSStripeBlock)completion;

@end
