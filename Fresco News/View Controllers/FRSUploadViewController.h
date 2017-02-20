//
//  FRSUploadViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 5/3/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import "FRSBaseViewController.h"

@interface FRSUploadViewController : FRSBaseViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSInteger selectedRow;
    NSInteger numberOfOutlets;
    unsigned long long contentSize;
    NSString *selectedOutlet;
}
@property (retain, nonatomic) UIButton *twitterButton;
@property (retain, nonatomic) UIButton *facebookButton;
@property (retain, nonatomic) UIButton *anonButton;
@property (retain, nonatomic) UILabel *anonLabel;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *assignmentsArray;
@property (strong, nonatomic) NSArray *globalAssignments;
@property (strong, nonatomic) NSDictionary *preselectedGlobalAssignment;
@property (strong, nonatomic) NSDictionary *preselectedAssignment;
@property (nonatomic, weak) NSArray *content;

- (void)configureAssignmentsTableView;

@end
