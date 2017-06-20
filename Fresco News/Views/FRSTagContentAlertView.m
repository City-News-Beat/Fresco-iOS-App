//
//  FRSTagContentAlertView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/30/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTagContentAlertView.h"
#import "FRSFileTagOptionsTableView.h"

@interface FRSTagContentAlertView ()

@property (strong, nonatomic) FRSFileTagOptionsTableView *fileTagOptionsTableView;

@end

@implementation FRSTagContentAlertView

- (instancetype)initTagContentAlertView {
    self = [super init];
    
    if (self) {
        /* Title Label */
        [self configureWithTitle:@""];
        
        [self configureFileTagOptionsTableView];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.fileTagOptionsTableView.frame.origin.y + self.fileTagOptionsTableView.frame.size.height + 15];
        
    }
    
    return self;
}


- (void)showAlertWithTagViewMode:(FRSTagViewMode)tagViewMode {
    [self removeUncommonViews];

    switch (tagViewMode) {
        case FRSTagViewModeNewTag:
            self.titleLabel.text = @"SET CONTENT TYPE";
            [self configureWithLeftActionTitle:@"CANCEL" withColor:nil andRightCancelTitle:@"" withColor:nil];

            break;
        case FRSTagViewModeEditTag:
            self.titleLabel.text = @"EDIT CONTENT TYPE";
            [self configureWithLeftActionTitle:@"CANCEL" withColor:nil andRightCancelTitle:@"REMOVE SELECTION" withColor:nil];

            break;
            
        default:
            break;
    }
    
    //table view
    self.fileTagOptionsTableView.sourceViewModelsArray = self.sourceViewModelsArray;
    [self.fileTagOptionsTableView reloadData];
    
    [self adjustFrame];
    [self show];
    
}

- (void)adjustFrame {
    self.height = self.titleLabel.frame.size.height + self.fileTagOptionsTableView.frame.size.height + self.leftActionButton.frame.size.height + 15;
    
    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
    NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;
    
    self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
}

- (void)removeUncommonViews {
    [self.leftActionButton removeFromSuperview];
    self.leftActionButton = nil;

    [self.rightCancelButton removeFromSuperview];
    self.rightCancelButton = nil;
}

#pragma mark - Table view

- (void)configureFileTagOptionsTableView {
    self.fileTagOptionsTableView = [[FRSFileTagOptionsTableView alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.bounds.size.width, 4*44) style:UITableViewStylePlain];
    self.fileTagOptionsTableView.sourceViewModelsArray = self.sourceViewModelsArray;
    [self addSubview:self.fileTagOptionsTableView];
    
    [self.fileTagOptionsTableView addObserver:self forKeyPath:@"selectedSourceViewModel" options:0 context:nil];

//    self.fileTagOptionsTableView.alpha = 0;
//    self.fileTagOptionsTableView.isExpanded = NO;
    
//    [self.fileTagOptionsTableView addObserver:self forKeyPath:@"selectedSourceViewModel" options:0 context:nil];
//    [self.fileTagOptionsTableView addObserver:self forKeyPath:@"isExpanded" options:0 context:nil];
 
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.fileTagOptionsTableView && [keyPath isEqualToString:@"selectedSourceViewModel"]) {
        self.selectedSourceViewModel = self.fileTagOptionsTableView.selectedSourceViewModel;
        [self dismiss];
    }
}

-(void)dealloc {
    [self.fileTagOptionsTableView removeObserver:self forKeyPath:@"selectedSourceViewModel"];
}

#pragma mark - Overrides

- (void)rightCancelTapped {
    [super rightCancelTapped];
    if([self.delegate respondsToSelector:@selector(removeSelection)]) {
        [self.delegate removeSelection];
    }
}

@end
