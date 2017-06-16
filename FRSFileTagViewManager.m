//
//  FRSFileTagViewManager.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagViewManager.h"
#import "FRSTagContentAlertView.h"
#import "FRSFileTag.h"
#import "FRSFileTagOptionsViewModel.h"
#import "PHAsset+Tagging.h"
#import "FRSCaptureModeEnumHelper.h"
#import "FRSFileTagManager.h"

@interface FRSFileTagViewManager ()<FRSTagContentAlertViewDelegate>

@property(strong, nonatomic) FRSTagContentAlertView *tagAlertView;
@property(strong, nonatomic) NSMutableArray *availableTags;
@property(strong, nonatomic) NSMutableArray *tagViewModels;
@property(strong, nonatomic) PHAsset *currentAsset;
@property(assign, nonatomic) FRSPackageProgressLevel packageProgressLevel;

@property(strong, nonatomic) NSMutableArray *interviewTaggedAssetsArray;
@property(strong, nonatomic) NSMutableArray *wideShotTaggedAssetsArray;
@property(strong, nonatomic) NSMutableArray *steadyPanTaggedAssetsArray;

@end

@implementation FRSFileTagViewManager

+ (FRSFileTagViewManager *)sharedInstance {
    static FRSFileTagViewManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.interviewTaggedAssetsArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.wideShotTaggedAssetsArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.steadyPanTaggedAssetsArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.packageProgressLevel = FRSPackageProgressLevelZero;
        [self setupTagAlertView];
        [self setupAvailableTagsAndViewModels];
    }
    return self;
}

- (void)setupTagAlertView {
    self.tagAlertView = [[FRSTagContentAlertView alloc] initTagContentAlertView];
    self.tagAlertView.delegate = self;
    [self.tagAlertView addObserver:self forKeyPath:@"selectedSourceViewModel" options:0 context:nil];
}

- (void)showTagViewForAsset:(PHAsset *)asset {
    self.currentAsset = asset;
    [self resetTagViewModels];
    
    FRSTagViewMode tagViewMode = FRSTagViewModeNewTag;
    
    FRSCaptureMode captureMode = [[FRSFileTagManager sharedInstance] fetchCaptureModeForAsset:asset];
    
    if([self isCaptureModeInRangeOfAvailableModes:captureMode]) {
        [self configureSelectedTagViewModelForCaptureMode: captureMode];
        tagViewMode = FRSTagViewModeEditTag;
    }
    
    self.tagAlertView.sourceViewModelsArray = self.tagViewModels;
    [self.tagAlertView showAlertWithTagViewMode:tagViewMode];
}

- (BOOL)isCaptureModeInRangeOfAvailableModes:(FRSCaptureMode)captureMode {
    if(captureMode == FRSCaptureModeVideoInterview || captureMode == FRSCaptureModeVideoPan || captureMode == FRSCaptureModeVideoWide || captureMode == FRSCaptureModeOther) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Tags
- (NSMutableArray *)availableTags {
    return _availableTags;
}

- (void)setupAvailableTagsAndViewModels {
    //models
    FRSFileTag *tag1 = [[FRSFileTag alloc] initWithName:FRSCaptureModeVideoInterview_StandardDisplayName];
    FRSFileTag *tag2 = [[FRSFileTag alloc] initWithName:FRSCaptureModeVideoWide_StandardDisplayName];
    FRSFileTag *tag3 = [[FRSFileTag alloc] initWithName:FRSCaptureModeVideoPan_StandardDisplayName];
    FRSFileTag *tag4 = [[FRSFileTag alloc] initWithName:FRSCaptureModeOther_StandardDisplayName];
    
    _availableTags = [[NSMutableArray alloc] initWithObjects:tag1, tag2, tag3, tag4, nil];
    
    //view models
    FRSFileTagOptionsViewModel *tagViewModel1 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag1];
    FRSFileTagOptionsViewModel *tagViewModel2 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag2];
    FRSFileTagOptionsViewModel *tagViewModel3 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag3];
    FRSFileTagOptionsViewModel *tagViewModel4 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag4];

    _tagViewModels = [[NSMutableArray alloc] initWithObjects:tagViewModel1, tagViewModel2, tagViewModel3, tagViewModel4, nil];

}

- (void)configureSelectedTagViewModelForCaptureMode:(FRSCaptureMode)assetCaptureMode {

    for (FRSFileTagOptionsViewModel *tagViewModel in _tagViewModels) {
        if(assetCaptureMode == tagViewModel.fileTag.captureMode) {
            tagViewModel.isSelected = YES;
            tagViewModel.nameText = tagViewModel.fileTag.name;
            tagViewModel.captureMode = tagViewModel.fileTag.captureMode;
            self.tagAlertView.selectedSourceViewModel = tagViewModel;
            break;
        }
    }
}

- (void)resetTagViewModels {
    for (FRSFileTagOptionsViewModel *tagViewModel in _tagViewModels) {
        tagViewModel.isSelected = NO;
        tagViewModel.captureMode = FRSCaptureModeOther;
    }
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.tagAlertView && [keyPath isEqualToString:@"selectedSourceViewModel"]) {
        NSLog(@"tag manager selectedSourceViewModel changed.");
        //self.selectedSourceViewModel = self.fileTagOptionsTableView.selectedSourceViewModel;
        self.currentAsset.fileTag = self.tagAlertView.selectedSourceViewModel.fileTag;
        self.tagUpdated = YES;
       // self.currentAsset.fileTag.captureMode = self.tagAlertView.selectedSourceViewModel.fileTag.captureMode;
       // self.currentAsset.fileTag.name = self.tagAlertView.selectedSourceViewModel.fileTag.name;
        
        [self saveCaptureModeForCurrentAsset:self.currentAsset.fileTag.captureMode];
        [self updateTaggedAssetsArrays];
        [self updatePackageProgressLevel];
    }
}

- (void)updateTaggedAssetsArrays {
    if([self.interviewTaggedAssetsArray containsObject:self.currentAsset]) {
        [self.interviewTaggedAssetsArray removeObject:self.currentAsset];
    }
    if([self.wideShotTaggedAssetsArray containsObject:self.currentAsset]) {
        [self.wideShotTaggedAssetsArray removeObject:self.currentAsset];
    }
    if([self.steadyPanTaggedAssetsArray containsObject:self.currentAsset]) {
        [self.steadyPanTaggedAssetsArray removeObject:self.currentAsset];
    }
    
    if(self.currentAsset.fileTag) {
        switch (self.currentAsset.fileTag.captureMode) {
            case FRSCaptureModeVideoInterview:
            {
                [self.interviewTaggedAssetsArray addObject:self.currentAsset];
            }
                break;
            case FRSCaptureModeVideoWide:
            {
                [self.wideShotTaggedAssetsArray addObject:self.currentAsset];
            }
                break;
            case FRSCaptureModeVideoPan:
            {
                [self.steadyPanTaggedAssetsArray addObject:self.currentAsset];
            }
                break;
                
            default:
                break;
        }
    }
}

- (FRSPackageProgressLevel)packageProgressLevel {
    return _packageProgressLevel;
}

- (void)updatePackageProgressLevel {
    NSInteger progress = 0;
    if(self.interviewTaggedAssetsArray.count > 0) {
        progress = progress + 1;
    }
    if(self.wideShotTaggedAssetsArray.count > 0) {
        progress = progress + 1;
    }
    if(self.steadyPanTaggedAssetsArray.count > 0) {
        progress = progress + 1;
    }
    
    self.packageProgressLevel = progress;
}

- (BOOL)isInterviewTagged {
    return self.interviewTaggedAssetsArray.count > 0;
}

- (BOOL)isWideShotTagged {
    return self.wideShotTaggedAssetsArray.count > 0;
}

- (BOOL)isSteadyPanTagged {
    return self.steadyPanTaggedAssetsArray.count > 0;
}

- (void)dealloc {
    [self.tagAlertView removeObserver:self forKeyPath:@"selectedSourceViewModel"];
}

#pragma mark - FRSTagContentAlertViewDelegate

- (void)removeSelection {
    if([self.delegate respondsToSelector:@selector(removeSelection)]) {
        [self.delegate removeSelection];
    }
}

#pragma mark - Tags Manager

- (void)saveCaptureModeForCurrentAsset:(FRSCaptureMode)captureMode {
    [[FRSFileTagManager sharedInstance] saveCaptureMode:captureMode forAsset:self.currentAsset];
}

- (void)clearAllCachedInfo {
    [self.interviewTaggedAssetsArray removeAllObjects];
    [self.wideShotTaggedAssetsArray removeAllObjects];
    [self.steadyPanTaggedAssetsArray removeAllObjects];
    
    _packageProgressLevel = FRSPackageProgressLevelZero;
}

@end
