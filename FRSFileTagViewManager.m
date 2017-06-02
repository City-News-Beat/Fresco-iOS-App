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

@interface FRSFileTagViewManager ()<FRSTagContentAlertViewDelegate>

@property(strong, nonatomic) FRSTagContentAlertView *tagAlertView;
@property(strong, nonatomic) NSMutableArray *availableTags;
@property(strong, nonatomic) NSMutableArray *tagViewModels;
@property(strong, nonatomic) PHAsset *currentAsset;

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
    self.tagAlertView.delegate = self;
    [self.tagAlertView addObserver:self forKeyPath:@"selectedSourceViewModel" options:0 context:nil];

}

- (void)showTagViewForCaptureMode:(FRSCaptureMode)captureMode andTagViewMode:(FRSTagViewMode)tagViewMode {
//    [self.tagAlertView showTagViewForCaptureMode:captureMode andTagViewMode:tagViewMode];
}

- (void)showTagViewForAsset:(PHAsset *)asset {
    self.currentAsset = asset;
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
        if(asset.fileTag.captureMode == tagViewModel.fileTag.captureMode) {
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
    }
}

-(void)dealloc {
    [self.tagAlertView removeObserver:self forKeyPath:@"selectedSourceViewModel"];
}

#pragma mark - FRSTagContentAlertViewDelegate

- (void)removeSelection {
    if([self.delegate respondsToSelector:@selector(removeSelection)]) {
        [self.delegate removeSelection];
    }
}


@end
