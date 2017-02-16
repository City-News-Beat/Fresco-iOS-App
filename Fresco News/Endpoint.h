//
//  Endpoint.h
//  Fresco
//
//  Created by User on 12/29/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>


//Analytics
static NSString *const segmentWriteKeyProd = @"WGfcEDU5pn9SMdGf5zjL0cgO3MAPLqHI"; // prod
static NSString *const segmentWriteKeyDev = @"SseDGQBsKVym6w3gv5Kxrg3wRoDMw29h"; // debug

//AWS
static NSString *const awsBucketDev = @"com.fresconews.dev";
static NSString *const awsAccessKeyDev = @"AKIAJRQQA26XTXPGVAKA";
static NSString *const awsSecretKeyDev = @"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";

static NSString *const awsBucketProd = @"com.fresconews.v2.prod";
static NSString *const awsAccessKeyProd = @"AKIAJRQQA26XTXPGVAKA";
static NSString *const awsSecretKeyProd = @"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";

//Authorization
static NSString *const clientIdProd = @"";
static NSString *const clientSecretProd = @"";

static NSString *const clientIdDev = @"FggpZkXKiur4zzFWOhkQJRcDQpsg0g8jgbazLYNcCf2RfSukoYutk2wSJLFf";
static NSString *const clientSecretDev = @"tI8a6k1oRuwi32hozZfLloVmyEzbpAvSxRnc6eKyiLUSq0eP61NFT03WOAewPcKQENayE986q6e2ajA97O9vr5PvnG9m3wNG6DGMkCNWpzKtkDBuYL1wBL8LOK7EDJJWYXljzzxcI6paSULEvAtI6YvneQmlBOYShvzhR0IMHl3roMNi3sK2MMIB3EKDQM";

//SDKs
static NSString *const twitterConsumeyKey = @"kT772ISFiuWQdVQblU4AmBWw3";
static NSString *const twitterConsumerSecret = @"navenvTSRCcyUL7F4Ait3gACnxfc7YXWyaee2bAX1sWnYGe4oY";
static NSString *const smoochToken = @"bmk6otjwgrb5wyaiohse0qbr0";
static NSString *const UXCamKey = @"641451390ede123";

//API
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
@property (nonatomic, strong) NSString *frescoClientSecret;
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
