//
//  Endpoint.m
//  Fresco
//
//  Created by User on 12/29/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "Endpoint.h"

@implementation Endpoint

- (void)setEndpoint:(int)endpointIndex {
    switch (endpointIndex) {
    case 0:
        self.endpointName = @"Dev";
        self.baseUrl = baseURLDev;
        self.stripeKey = stripeTest;
        self.frescoWebsite = webURLDev;
        self.frescoClientId = clientIdDev;
        self.frescoClientSecret = clientSecretDev;
        self.twitterConsumerKey = twitterConsumeyKey;
        self.twitterConsumerSecret = twitterConsumerSecret;
        self.smoochToken = smoochToken;
        self.amazonS3Bucket = awsBucketDev;
        self.amazonS3AccessKey = awsAccessKeyDev;
        self.amazonS3SecretKey = awsSecretKeyDev;
        break;
    case 1:
        self.endpointName = @"Prod";
        self.baseUrl = baseURLProd;
        self.stripeKey = stripeLive;
        self.frescoWebsite = webURLProd;
        self.frescoClientId = clientIdProd;
        self.frescoClientSecret = clientSecretProd;
        self.twitterConsumerKey = twitterConsumeyKey;
        self.twitterConsumerSecret = twitterConsumerSecret;
        self.smoochToken = smoochToken;
        self.amazonS3Bucket = awsBucketProd;
        self.amazonS3AccessKey = awsAccessKeyProd;
        self.amazonS3SecretKey = awsSecretKeyProd;
    default:
        break;
    }
}

@end
