//
//  FRSPaymentManager.m
//  Fresco
//
//  Created by User on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSPaymentManager.h"
#import "FRSRequestSerializer.h"
#import "EndpointManager.h"

static NSString *const createPayment = @"user/payment/create";
static NSString *const getPaymentsEndpoint = @"user/payment";
static NSString *const deletePaymentEndpoint = @"user/payment/%@/delete";
static NSString *const makePaymentActiveEndpoint = @"user/payment/%@/update/";
static NSString *const setStateIDEndpoint = @"https://uploads.stripe.com/v1/files";
static NSString *const updateTaxInfoEndpoint = @"user/identity/update";

@implementation FRSPaymentManager

+ (instancetype)sharedInstance {
    static FRSPaymentManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSPaymentManager alloc] init];
    });
    return instance;
}

- (void)fetchPayments:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:getPaymentsEndpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)createPaymentWithToken:(nonnull NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {

    if (!token) {
        completion(Nil, Nil);
    }

    [[FRSAPIClient sharedClient] post:createPayment
        withParameters:@{ @"token" : token,
                          @"active" : @(TRUE) }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)deletePayment:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:deletePaymentEndpoint, paymentID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)makePaymentActive:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:makePaymentActiveEndpoint, paymentID];

    NSDictionary *params = @{ @"active" : @(1) };

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {

                             completion(responseObject, error);
                           }];
}

- (void)uploadStateIDWithParameters:(NSData *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:setStateIDEndpoint]];
    manager.requestSerializer = [[FRSRequestSerializer alloc] init];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [[FRSJSONResponseSerializer alloc] init];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [EndpointManager sharedInstance].currentEndpoint.stripeKey];

    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];

    [manager POST:setStateIDEndpoint
        parameters:nil
        constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
          [formData appendPartWithFileData:parameters name:@"file" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
          [formData appendPartWithFormData:[@"identity_document" dataUsingEncoding:NSUTF8StringEncoding] name:@"purpose"];
        }
        progress:^(NSProgress *_Nonnull uploadProgress) {
        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
          completion(responseObject, Nil);
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
          completion(Nil, error);
        }];
}

- (void)updateTaxInfoWithFileID:(NSString *)fileID completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:updateTaxInfoEndpoint
        withParameters:@{ @"stripe_document_token" : fileID }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

@end
