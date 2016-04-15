//
//  FRSSearchViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSearchViewController.h"
#import "FRSTableViewCell.h"

@interface FRSSearchViewController() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIButton *clearButton;

@end

@implementation FRSSearchViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.searchTextField resignFirstResponder];
}

-(void)dismiss{

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clear{
    self.searchTextField.text = @"";
    [self hideClearButton];
    [self.searchTextField resignFirstResponder];
}

#pragma mark - UI
-(void)configureNavigationBar {

    UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [container addSubview:backButton];
    backButton.tintColor = [UIColor whiteColor];
    backButton.frame = CGRectMake(-3, 0, 24, 24);
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:container];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.navigationItem.titleView = titleView;
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(19, 17, self.view.frame.size.width - 80, 30)];
    self.searchTextField.tintColor = [UIColor whiteColor];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{ NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.3], NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightMedium] }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.searchTextField];
    
    [titleView addSubview:self.searchTextField];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clearButton.frame = CGRectMake(self.view.frame.size.width - 80, 20, 24, 24);
    [self.clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    self.clearButton.tintColor = [UIColor whiteColor];
    [self.clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    self.clearButton.alpha = 0;
    
    [titleView addSubview:self.clearButton];

}

-(void)showClearButton {
    
    //Scale clearButton up with a little jiggle
    [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.clearButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            self.clearButton.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    }];
    
    //Fade in clearButton over total duration of scale
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.clearButton.alpha = 1;
    } completion:nil];
}

-(void)hideClearButton {
    
    //Scale clearButton down with anticipation
    [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.clearButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            self.clearButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001); //iOS does not scale to (0,0) for some reason :(
            self.clearButton.alpha = 0;
        } completion:nil];
    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange:(NSNotification *)notification {
    if ((![self.searchTextField.text isEqual: @""]) && (self.clearButton.alpha == 0)) {
        [self showClearButton];
    } else if ([self.searchTextField.text isEqual:@""]){
        [self hideClearButton];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self.searchTextField.text isEqualToString: @""]) {
        [self showClearButton];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideClearButton];
}

#pragma mark - UITableView Datasource

-(void)configureTableView{
    self.title = @"";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 47;
                    break;
                case 1:
                    return 56;
                    break;
                case 2:
                    return 56;
                    break;
                case 3:
                    return 56;
                    break;
                case 4:
                    return 44;
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    return 47;
                    break;
                case 1:
                    return 56;
                    break;
                case 2:
                    return 56;
                    break;
                case 3:
                    return 56;
                    break;
                case 4:
                    return 44;
                    break;
                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    return 24;
                    break;
                case 1:
                    return 44;
                    break;
                case 2:
                    return 44;
                    break;
                case 3:
                    return 44;
                    break;
                case 4:
                    return 44;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return 0;
}

-(FRSTableViewCell *)tableView:(FRSTableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier;
    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell configureSettingsHeaderCellWithTitle:@"USERS"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    [cell configureSearchUserCellWithProfilePhoto:[UIImage imageNamed:@"apple-user-grace"] fullName:@"Grace Plihal" userName:@"@DJgracieP" isFollowing:YES];
                    break;
                case 2:
                    [cell configureSearchUserCellWithProfilePhoto:[UIImage imageNamed:@"apple-user-byrn"] fullName:@"Bryn Gelbart" userName:@"@bryn" isFollowing:NO];
                    break;
                case 3:
                    [cell configureSearchUserCellWithProfilePhoto:[UIImage imageNamed:@"apple-user-erik"] fullName:@"Erik Washington" userName:@"@erik" isFollowing:NO];
                    break;
                case 4:
                    [cell configureSearchSeeAllCellWithTitle:@"SEE ALL 11 USERS"];
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell configureSettingsHeaderCellWithTitle:@"STORIES"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    [cell configureSearchStoryCellWithStoryPhoto:[UIImage imageNamed:@"apple-story-1"] storyName:@"Mardi Gras Celebration: New Orleans, LA"];
                    break;
                case 2:
                    [cell configureSearchStoryCellWithStoryPhoto:[UIImage imageNamed:@"apple-story-2"] storyName:@"MLS Finals: Columbus, OH"];
                    break;
                case 3:
                    [cell configureSearchStoryCellWithStoryPhoto:[UIImage imageNamed:@"apple-story-3"] storyName:@"Warehouse Fire: Hillsborough, NJ"];
                    break;
                case 4:
                    [cell configureSearchSeeAllCellWithTitle:@"SEE ALL 25 STORIES"];
                    break;
                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell configureSettingsHeaderCellWithTitle:@""];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    break;
                case 4:
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - dealloc
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end