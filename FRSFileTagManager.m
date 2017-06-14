//
//  FRSFileTagManager.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagManager.h"
#import "FRSTaggedAssetModel+CoreDataClass.h"
#import "MagicalRecord.h"


@interface FRSFileTagManager ()

@property (nonatomic, weak) NSManagedObjectContext *context;

@end

@implementation FRSFileTagManager

+ (FRSFileTagManager *)sharedInstance {
    static FRSFileTagManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.context = delegate.coreDataController.managedObjectContext;

    }
    return self;
}

- (void)saveCaptureMode:(FRSCaptureMode)captureMode forAsset:(PHAsset *)asset {
    if (!asset) return;

    [self saveCaptureMode:captureMode forAssetWithLocalIdentifier:asset.localIdentifier];
}

- (NSArray *)fetchCachedTaggedAssetModelForLocalIdentifier:(NSString *)localIdentifier {
    NSPredicate *assetModelPredicate = [FRSTaggedAssetModel predicateWithLocalIdentifier:localIdentifier];
    NSFetchRequest *assetModelRequest = [FRSTaggedAssetModel fetchRequest];
    assetModelRequest.predicate = assetModelPredicate;
    
    NSError *fetchError;
    NSArray *assetModels = [self.context executeFetchRequest:assetModelRequest error:&fetchError];
    
    if (fetchError) return nil;
    
    return assetModels;
}

- (BOOL)isAssetTagged:(PHAsset *)asset {
    NSArray *assetModels =  [self fetchCachedTaggedAssetModelForLocalIdentifier:asset.localIdentifier];
    if(assetModels == nil)
        return NO;
    else return YES;
}

- (FRSCaptureMode)fetchCaptureModeForAsset:(PHAsset *)asset {
    FRSCaptureMode captureMode = FRSCaptureModeInvalid;

    if (!asset) return captureMode;
    
    NSArray *assetModels =  [self fetchCachedTaggedAssetModelForLocalIdentifier:asset.localIdentifier];
    if(assetModels && assetModels.count>0) {
        FRSTaggedAssetModel *assetModel = assetModels[0];
        captureMode = assetModel.captureMode.integerValue;
    }
    return captureMode;
}

- (void)saveCaptureMode:(FRSCaptureMode)captureMode forAssetWithLocalIdentifier:(NSString *)localIdentifier {
    if (!localIdentifier) return;
    
    NSArray *assetModels =  [self fetchCachedTaggedAssetModelForLocalIdentifier:localIdentifier];
    
    
    if(assetModels && assetModels.count>0) {
        //update
        FRSTaggedAssetModel *assetModel = assetModels[0];
        if (assetModel.captureMode.integerValue != captureMode) {
            assetModel.captureMode = @(captureMode);
        }
    }
    else {
        //create new
        FRSTaggedAssetModel *assetModel = [FRSTaggedAssetModel insertNewObjectIntoContext:self.context];
        assetModel.localIdentifier = localIdentifier;
        assetModel.captureMode = @(captureMode);
    }
    
    [self.context save:nil];

}



@end
