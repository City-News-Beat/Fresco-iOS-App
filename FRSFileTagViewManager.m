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

@interface FRSFileTagViewManager ()

@property(weak, nonatomic) id<FRSFileTagViewManagerDelegate> delegate;
@property(strong, nonatomic) FRSTagContentAlertView *tagAlertView;
@property(strong, nonatomic) NSMutableArray *availableTags;
@property(strong, nonatomic) NSMutableArray *tagViewModels;

@end

@implementation FRSFileTagViewManager

- (instancetype)initWithDelegate:(id<FRSFileTagViewManagerDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        [self setupTagAlertView];
        [self setupAvailableTagsAndViewModels];
    }
    return self;
}

- (void)setupTagAlertView {
    self.tagAlertView = [[FRSTagContentAlertView alloc] initTagContentAlertView];
}

- (void)showTagViewForCaptureMode:(FRSCaptureMode)captureMode andTagViewMode:(FRSTagViewMode)tagViewMode {
//    [self.tagAlertView showTagViewForCaptureMode:captureMode andTagViewMode:tagViewMode];
}

- (void)showTagViewForAsset:(PHAsset *)asset {
    [self resetTagViewModels];
    
    FRSTagViewMode tagViewMode = FRSTagViewModeNewTag;
    
    if(asset.fileTag) {
        [self configureSelectedTagViewModelForAsset: asset];
        tagViewMode = FRSTagViewModeEditTag;
    }
    
    self.tagAlertView.sourceViewModelsArray = self.tagViewModels;
    [self.tagAlertView showAlertWithTagViewMode:tagViewMode];
}

#pragma mark - Tags
- (NSMutableArray *)availableTags {
    return _availableTags;
}

- (void)setupAvailableTagsAndViewModels {
    //models
    FRSFileTag *tag1 = [[FRSFileTag alloc] initWithName:@"Interview"];
    FRSFileTag *tag2 = [[FRSFileTag alloc] initWithName:@"Wide Shot"];
    FRSFileTag *tag3 = [[FRSFileTag alloc] initWithName:@"Steady Pan"];
    FRSFileTag *tag4 = [[FRSFileTag alloc] initWithName:@"Other"];
    
    _availableTags = [[NSMutableArray alloc] initWithObjects:tag1, tag2, tag3, tag4, nil];
    
    //view models
    FRSFileTagOptionsViewModel *tagViewModel1 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag1];
    FRSFileTagOptionsViewModel *tagViewModel2 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag2];
    FRSFileTagOptionsViewModel *tagViewModel3 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag3];
    FRSFileTagOptionsViewModel *tagViewModel4 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag4];

    _tagViewModels = [[NSMutableArray alloc] initWithObjects:tagViewModel1, tagViewModel2, tagViewModel3, tagViewModel4, nil];

}

- (void)configureSelectedTagViewModelForAsset:(PHAsset *)asset {
    for (FRSFileTagOptionsViewModel *tagViewModel in _tagViewModels) {
        if(asset.fileTag.captureMode == tagViewModel.captureMode) {
            tagViewModel.isSelected = YES;
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

@end
