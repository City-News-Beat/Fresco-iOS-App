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

/*
    Note: Stripe only cares about "individual" (human) vs "company" (corporate entity) accounts
 */

static NSString * const stripeTest = @"pk_test_o4pMXyj95Vqe5NgV3hb7qmdo";
static NSString * const stripeLive = @"pk_live_saSjliYnCbjFwYfriTzhTQiO";

typedef enum {
    FRSBankAccountTypeIndividual,
    FRSBankAccountTypeCorporate
} FRSBankAccountType;

@interface FRSStripe : NSObject

// credit cards
+(STPCardParams *)creditCardWithNumber:(NSString *)number expiration:(NSArray *)expiration cvc:(NSString *)cvc;
+(STPCardParams *)creditCardWithNumber:(NSString *)number expiration:(NSArray *)expiration cvc:(NSString *)cvc firstName:(NSString *)firstName lastName:(NSString *)lastName;

+(void)createTokenWithCard:(STPCardParams *)params completion:(FRSStripeBlock)completion;

// bank accounts
+(STPBankAccountParams *)bankAccountWithNumber:(NSString *)number routing:(NSString *)routing name:(NSString *)name ssn:(NSString *)last4 type:(FRSBankAccountType)holderType;
+(void)createTokenWithBank:(STPBankAccountParams *)params completion:(FRSStripeBlock)completion;
+(void)startLive;
+(void)startTest;
/*
 
    Personal note:
 
    Dealing with documents: licenses, etc??
 
    Notes on banks, what it appears stripe looks for:
 
    @"accountNumber": @"account_number",
    @"routingNumber": @"routing_number",
    @"country": @"country",
    @"currency": @"currency",
    @"accountHolderName": @"account_holder_name",
    @"accountHolderTypeString": @"account_holder_type",
 */

@end
