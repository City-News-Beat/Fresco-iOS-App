//
//  Endpoint.h
//  Fresco
//
//  Created by Maurice Wu on 12/29/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const awsBucketDev = @"com.fresconews.dev";
static NSString *const awsAccessKeyDev = @"AKIAJRQQA26XTXPGVAKA";
static NSString *const awsSecretKeyDev = @"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";

static NSString *const segmentWriteKeyProd = @"WGfcEDU5pn9SMdGf5zjL0cgO3MAPLqHI"; // prod
static NSString *const segmentWriteKeyDev = @"SseDGQBsKVym6w3gv5Kxrg3wRoDMw29h"; // debug

static NSString *const awsBucketProd = @"com.fresconews.v2.prod";
static NSString *const awsAccessKeyProd = @"AKIAJRQQA26XTXPGVAKA";
static NSString *const awsSecretKeyProd = @"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";

static NSString *const clientAuthorizationProd = @"TkJzcGtLWjcyZk1WQnhtV01LcHR6cm5kVm10TkxLWFk1WFY2ZjVDQjJUdEE4dk1OcnRwMlRtZFpQUVZNOnFoYTlrRVZnM3k5ZXZnSmM4TVdoZ3JFakg0dmh0TDZYdUU4c1BROHlKYXZyY3J1ZmdGalhiQVRDS3RmOGZ3U0ZDNUZDZlhWOXpLSHlZVTdEM0hhcEJDUUJKcXRrOHF3OXBHdmVlRzNCRmIzQ3lRZ05GOHVibWZwZDZQMndLYkY3YUttYnN5ajdKa1ZqWGRkZmo4U25NcHFDYXR6ZUVtSzRScllnd2hyZVZkcFl2SlN1cTZFbXJ2N1dYdGpYVUo=";
static NSString *const clientAuthorizationDev = @"MTMzNzp0aGlzaXNhc2VjcmV0";

static NSString *const twitterConsumeyKey = @"kT772ISFiuWQdVQblU4AmBWw3";
static NSString *const twitterConsumerSecret = @"navenvTSRCcyUL7F4Ait3gACnxfc7YXWyaee2bAX1sWnYGe4oY";
static NSString *const smoochToken = @"bmk6otjwgrb5wyaiohse0qbr0";
static NSString *const UXCamKey = @"641451390ede123";

static NSString *const baseURLDev = @"https://api.dev.fresconews.com/v2/";
static NSString *const baseURLProd = @"https://api.fresconews.com/v2/";
static NSString *const webURLDev = @"https://dev.fresconews.com";
static NSString *const webURLProd = @"https://fresconews.com";
static NSString *const stripeTest = @"pk_test_o4pMXyj95Vqe5NgV3hb7qmdo";
static NSString *const stripeLive = @"pk_live_saSjliYnCbjFwYfriTzhTQiO";

@interface Endpoint : NSObject

@property (nonatomic, strong) NSString *endpointName;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *stripeKey;
@property (nonatomic, strong) NSString *frescoWebsite;
@property (nonatomic, strong) NSString *frescoClientId;
@property (nonatomic, strong) NSString *twitterConsumerKey;
@property (nonatomic, strong) NSString *twitterConsumerSecret;
@property (nonatomic, strong) NSString *smoochToken;
@property (nonatomic, strong) NSString *amazonS3AccessKey;
@property (nonatomic, strong) NSString *amazonS3SecretKey;
@property (nonatomic, strong) NSString *amazonS3Bucket;
@property (nonatomic, strong) NSString *segmentKey;
@property (nonatomic, strong) NSString *UXCamKey;

- (void)setEndpoint:(int)endpointIndex;

@end
