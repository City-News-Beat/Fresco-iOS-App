//
//  FRSSearchViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSearchViewController.h"
#import "FRSTableViewCell.h"
#import "FRSGallery.h"
#import "FRSGalleryCell.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSScrollingViewController.h"
#import "FRSUser.h"
#import "FRSProfileViewController.h"
#import "FRSStoryDetailViewController.h"
//#import <MagicalRecord/MagicalRecord.h>
#import "FRSAwkwardView.h"
#import "DGElasticPullToRefresh.h"
#import "FRSAlertView.h"

@interface FRSSearchViewController () <UITableViewDelegate, UITableViewDataSource, FRSTableViewCellDelegate, FRSGalleryViewDelegate, FRSStoryViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) FRSAwkwardView *awkwardView;
@property (strong, nonatomic) UIButton *backTapButton;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property BOOL userExtended;
@property BOOL storyExtended;
@property BOOL onlyDisplayGalleries;
@property BOOL configuredNearby;

@property NSInteger usersDisplayed;
@property NSInteger storiesDisplayed;
@property (nonatomic, retain) NSDate *currentQuery;
@property (strong, nonatomic) FRSAlertView *alert;
@property (strong, nonatomic) NSString *userSectionTitleString;
@property (strong, nonatomic) UIView *nearbyHeaderContainer;

@end

@implementation FRSSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
    [self.navigationController setNavigationBarHidden:NO];

    userIndex = 0;
    storyIndex = 1;
    galleryIndex = 2;

    [self.searchTextField becomeFirstResponder];

    self.configuredNearby = YES;
    [self configureNearbyUsers];

    self.userSectionTitleString = @"";

    // Tab bar should always be visible in this view controller
    [self showTabBarAnimated:NO];
}

- (void)search:(NSString *)string {
    defaultSearch = string;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchTextField resignFirstResponder];
    self.shouldUpdateOnReturn = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.backTapButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (defaultSearch) {
        self.searchTextField.text = defaultSearch;
    }

    if (self.shouldUpdateOnReturn) {
        [self performSearchWithQuery:self.searchTextField.text];
    } else {
        self.shouldUpdateOnReturn = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (defaultSearch) {
        [self performSearchWithQuery:defaultSearch];
    }
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
    [self.backTapButton removeFromSuperview];
}

- (void)clear {
    self.searchTextField.text = @"";
    [self hideClearButton];
    //    [self.searchTextField resignFirstResponder];
}

- (void)configureSpinner {

    if (self.loadingView) {
        return;
    }

    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

- (void)removeSpinner {
    [self.loadingView stopLoading];
    self.loadingView.alpha = 0;
    [self.loadingView removeFromSuperview];
}

#pragma mark - UI
- (void)configureNavigationBar {

    UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [container addSubview:backButton];

    backButton.tintColor = [UIColor whiteColor];
    //    backButton.backgroundColor = [UIColor redColor];
    backButton.frame = CGRectMake(-15, -12, 48, 48);
    backButton.imageView.frame = CGRectMake(-12, 0, 48, 48); //this doesnt change anything
    //    backButton.imageView.backgroundColor = [UIColor greenColor];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:container];

    //    self.backTapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    //    [self.backTapButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    //    self.backTapButton.backgroundColor = [UIColor blueColor];
    //    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backTapButton];

    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    //    [view addGestureRecognizer:tap];

    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.navigationItem.titleView = titleView;

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(19, 17, self.view.frame.size.width - 80, 30)];
    self.searchTextField.tintColor = [UIColor whiteColor];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.3], NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightMedium] }];

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

- (void)showClearButton {

    //    //Scale clearButton up with a little jiggle
    //    [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
    //        self.clearButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
    self.clearButton.transform = CGAffineTransformMakeScale(1, 1);
    //        } completion:nil];
    //    }];

    //    //Fade in clearButton over total duration of scale
    //    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
    self.clearButton.alpha = 1;
    //    } completion:nil];
}

- (void)hideClearButton {

    //    //Scale clearButton down with anticipation
    //    [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
    //        self.clearButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
    self.clearButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001); //iOS does not scale to (0,0) for some reason :(
    self.clearButton.alpha = 0;
    //        } completion:nil];
    //    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    if ((![self.searchTextField.text isEqual:@""]) && (self.clearButton.alpha == 0)) {
        [self showClearButton];
    } else if ([self.searchTextField.text isEqual:@""]) {
        [self hideClearButton];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self.searchTextField.text isEqualToString:@""]) {
        [self showClearButton];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideClearButton];
    [self.awkwardView removeFromSuperview];
    self.awkwardView = nil;
    if (textField.text) {
        [self performSearchWithQuery:textField.text];
    }
}

- (void)performSearchWithQuery:(NSString *)query {
    _storyExtended = NO;
    _userExtended = NO;

    if ([query isEqualToString:@""]) {
        return;
    }

    self.configuredNearby = NO;

    [self configureSpinner];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.nearbyHeaderContainer.alpha = 0;
    });
    self.users = @[];
    self.galleries = @[];
    self.stories = @[];
    [self reloadData];
    __block NSDate *date = [NSDate date];

    self.currentQuery = date;

    [[FRSAPIClient sharedClient] searchWithQuery:query
                                      completion:^(id responseObject, NSError *error) {

                                        if (date != self.currentQuery) {
                                            return;
                                        }

                                        [self removeSpinner];
                                        if (error || !responseObject) {
                                            [self searchError:error];
                                            return;
                                        }

                                        self.userSectionTitleString = @"USERS";

                                        //NSString *filePath = @"";
                                        //NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@"file://path"] options:0 error:Nil];

                                        NSDictionary *storyObject = responseObject[@"stories"];
                                        NSDictionary *galleryObject = responseObject[@"galleries"];
                                        NSDictionary *userObject = responseObject[@"users"];
                                        self.galleries = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleryObject[@"results"] cache:NO];
                                        self.users = userObject[@"results"];
                                        self.stories = storyObject[@"results"];

                                        [self rearrangeIndexes];

                                        [self reloadData];

                                        if (self.users.count == 0 && self.galleries.count == 0 && self.stories.count == 0) {
                                            [self configureNoResults];
                                        } else {
                                            self.awkwardView.alpha = 0;
                                            [self.awkwardView removeFromSuperview];
                                        }

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                          self.nearbyHeaderContainer.alpha = 0;
                                        });
                                      }];
}

- (void)configureNearbyUsers {

    [[FRSAPIClient sharedClient] fetchNearbyUsersWithCompletion:^(id responseObject, NSError *error) {

      if (error) {
          self.configuredNearby = NO;
          return;
      }

      if (![self.searchTextField.text isEqualToString:@""]) {
          return;
      }

      self.configuredNearby = YES;

      self.nearbyHeaderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -70, self.view.frame.size.width, 100)];
      [self.tableView addSubview:self.nearbyHeaderContainer];

      UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, self.nearbyHeaderContainer.frame.size.width, 31)];
      titleLabel.textAlignment = NSTextAlignmentCenter;
      titleLabel.text = @"Suggested users";
      titleLabel.textColor = [UIColor frescoDarkTextColor];
      titleLabel.font = [UIFont karminaBoldWithSize:28];
      [self.nearbyHeaderContainer addSubview:titleLabel];

      UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 57, self.nearbyHeaderContainer.frame.size.width, 20)];
      subtitleLabel.textAlignment = NSTextAlignmentCenter;
      subtitleLabel.text = @"Active citizen journalists in your area:";
      subtitleLabel.textColor = [UIColor frescoMediumTextColor];
      subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
      [self.nearbyHeaderContainer addSubview:subtitleLabel];

      self.users = responseObject;
      self.tableView.contentInset = UIEdgeInsetsMake(82, 0, 0, 0);
      self.tableView.bounces = YES;
      userIndex = 0;
      galleryIndex = 1;
      storyIndex = 2;

      [self removeSpinner];
      [self reloadData];

      _userExtended = YES;
      [self.tableView reloadData];

    }];
}

- (void)rearrangeIndexes {
    //By changing the index we bump the given tableview group up when there aren't any results for that query.

    //If no users and no stories are returned, bump galleries to top
    if (self.users.count == 0 && self.stories.count == 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-70, 0, -70, 0);
        userIndex = 2;
        storyIndex = 1;
        galleryIndex = 0;
    } else if (self.users.count != 0 && self.stories.count != 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-17, 0, -32, 0);
    }

    //If no users are returned, bump stories and galleries up one index
    if (self.users.count == 0) {
        userIndex = 2;
        storyIndex = 0;
        galleryIndex = 1;
    } else if (self.users.count != 0 && self.stories.count == 0 && self.galleries.count == 0) { //Only users are returned
        self.tableView.contentInset = UIEdgeInsetsMake(-17, 0, -56, 0);
        userIndex = 0;
        storyIndex = 1;
        galleryIndex = 2;
    }

    //If no stories are returnd, swap the indicies of galleries and stories
    if (self.stories.count == 0) {
        userIndex = 0;
        storyIndex = 2;
        galleryIndex = 1;
    } else if (self.stories.count != 0 && self.users.count == 0 && self.galleries.count == 0) { //Only stories are returned
        self.tableView.contentInset = UIEdgeInsetsMake(-17, 0, -56, 0);
        userIndex = 1;
        storyIndex = 0;
        galleryIndex = 2;
    }

    //If users, stories, and galleries are returned
    if (self.users.count != 0 && self.stories.count != 0 && self.galleries.count != 0) {
        userIndex = 0;
        storyIndex = 1;
        galleryIndex = 2;
    }

    //If users are returned with galleries
    if (self.users.count != 0 && self.galleries.count != 0 && self.stories.count == 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-17, 0, -67, 0);
        userIndex = 0;
        storyIndex = 2;
        galleryIndex = 1;
    }

    //If stories are returned with galleries
    if (self.stories.count != 0 && self.galleries.count != 0 && self.users.count == 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-17, 0, -68, 0);
        userIndex = 2;
        storyIndex = 0;
        galleryIndex = 1;
    }

    //If users are returned with stories
    if (self.stories.count != 0 && self.users.count != 0 && self.galleries.count == 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-17, 0, -56, 0);
        userIndex = 0;
        storyIndex = 1;
        galleryIndex = 2;
    }
}

- (void)reloadData {

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
    });
}
- (void)searchError:(NSError *)error {

    if (error.code == -1009) {
        self.alert = [[FRSAlertView alloc] initNoConnectionBannerWithBackButton:YES];
        [self.alert show];
        return;
    } else {
        [self presentGenericError];
    }
}

- (void)configureNoResults {
    if (!self.awkwardView) {
        self.awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 64, self.view.frame.size.width, self.view.frame.size.height / 2)];
        [self.tableView addSubview:self.awkwardView];
    }
}

#pragma mark - UITableView Datasource

- (void)configureTableView {
    self.title = @"";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 44) style:UITableViewStyleGrouped];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, -32, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    int numberOfSections = 0;
    if (_users && ![_users isEqual:[NSNull null]]) {
        numberOfSections++;
    }
    if (_stories && ![_stories isEqual:[NSNull null]]) {
        numberOfSections++;
    }
    if (_galleries && ![_galleries isEqual:[NSNull null]]) {
        numberOfSections++;
    }

    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == userIndex) {

        if (_users.count == 0) {
            return 0;
        }

        if (_userExtended) {
            return _users.count;
        }

        if (_users.count == 0) {
            return 0;
        }

        if (_users.count > 3) {
            return 4;
        } else {
            return _users.count;
        }

        return _users.count + 2;
    }
    if (section == storyIndex) {

        if (_stories.count == 0) {
            return 0;
        }

        if (_storyExtended) {
            return _stories.count;
        }
        if (_stories.count == 0) {
            return 0;
        }

        if (_stories.count >= 3) {
            return 4;
        } else {
            return _stories.count;
        }

        return 0; //Will never get called
    }
    if (section == galleryIndex) {
        return self.galleries.count;
    }

    return 0;
}

- (BOOL)isNoData {
    return TRUE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == storyIndex) {

        if (_stories.count == 0) {
            return 0;
        }
        if (indexPath.row == 3 && !_storyExtended) {
            return 44;
        }

        return 56;
    }

    if (indexPath.section == userIndex) {

        if (_users.count <= 0) {
            return 0;
        }
        if (indexPath.row == 3 && !_userExtended) {
            return 44;
        }

        if (self.configuredNearby) {

            NSDictionary *user = [self.users objectAtIndex:indexPath.row];

            if ([user[@"bio"] isEqualToString:@""] || [user[@"bio"] isEqual:[NSNull null]] || user[@"bio"] == nil) {
                return 66;
            } else {

                //This label is never added to the view, it's just used to calculate the height.
                NSString *bio = user[@"bio"];
                UILabel *bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 34, [UIScreen mainScreen].bounds.size.width - 72 - 56, 0)];
                bioLabel.text = (bio && ![bio isEqual:[NSNull null]] && ![bio isEqualToString:@""]) ? bio : @"";
                bioLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
                bioLabel.textColor = [UIColor frescoMediumTextColor];
                bioLabel.numberOfLines = 0;
                [bioLabel sizeToFit];
                bioLabel.frame = CGRectMake(72, 34, [UIScreen mainScreen].bounds.size.width - 72 - 56, bioLabel.frame.size.height);

                return bioLabel.frame.size.height + 34 + 24;
            }
        }

        return 56;
    } else {
        // galleries

        if (self.galleries.count <= 0) {
            return 0;
        }

        FRSGallery *gallery = [self.galleries objectAtIndex:indexPath.row];
        return [gallery heightForGallery] - 19 + 12; //-19px is the default bottom space height, should be 12px
    }

    return 0;
}

- (void)pushStoryView:(NSString *)storyID inRow:(NSInteger)row {
    NSManagedObjectContext *context = [[FRSAPIClient sharedClient] managedObjectContext];
    FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:context];

    story.uid = storyID;
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:story];

    if (self.stories[row][@"title"] && ![self.stories[row][@"title"] isEqual:[NSNull null]]) {
        detailView.title = self.stories[row][@"title"];
    }
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section == userIndex && self.users.count > 0 && self.users)) {
        return 30;
    }

    if ((section == storyIndex && self.stories.count > 0)) {
        return 30;
    }

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == galleryIndex) {
        return [UIView new];
    }

    if (section == userIndex && self.users.count == 0) {
        return [UIView new];
    }
    if (section == storyIndex && self.stories.count == 0) {
        return [UIView new];
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 47)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, tableView.frame.size.width - 32, 17)];
    [label setFont:[UIFont notaBoldWithSize:15]];
    [label setTextColor:[UIColor frescoMediumTextColor]];
    NSString *title = @"";

    if (section == userIndex && self.users.count > 0) {
        title = self.userSectionTitleString;
    }

    if (section == storyIndex && self.stories.count > 0) {
        title = @"STORIES";
    }

    [label setText:title];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor frescoBackgroundColorDark]];
    return view;
}

- (UITableViewCell *)tableView:(FRSTableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *galleryIdentifier;
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

    if (indexPath.section == userIndex) {
        cell.delegate = self;
        if (self.users.count == 0) {
            return Nil;
        }

        if (indexPath.row == 3 && !_userExtended) {
            [cell configureSearchSeeAllCellWithTitle:[NSString stringWithFormat:@"SEE ALL %lu USERS", self.users.count]];
            return cell;
        }

        if ((indexPath.row == self.users.count + 1) || (indexPath.row == 6 && !_userExtended) || (self.users.count < 5 && indexPath.row == self.users.count)) {
            [cell configureEmptyCellSpace:NO];
            return cell;
        }

        // users
        NSDictionary *user = self.users[indexPath.row];

        NSString *avatarURL;
        if ([user objectForKey:@"avatar"] || ![[user objectForKey:@"avatar"] isEqual:[NSNull null]]) {
            avatarURL = user[@"avatar"];
        }

        NSURL *avatarURLObject;

        if (avatarURL && ![avatarURL isEqual:[NSNull null]]) {
            avatarURLObject = [NSURL URLWithString:avatarURL];
        }

        NSString *firstname = @" ";
        if (user[@"full_name"] || ![user[@"full_name"] isEqual:[NSNull null]]) {
            firstname = user[@"full_name"];
        }

        NSString *username = @" ";
        if (user[@"username"] || ![user[@"username"] isEqual:[NSNull null]]) {
            username = user[@"username"];
        }

        if (self.configuredNearby) {

            [cell configureSearchNearbyUserCellWithProfilePhoto:avatarURLObject fullName:firstname userName:username isFollowing:[user[@"following"] boolValue] userDict:self.users[indexPath.row] user:nil];
        } else {
            [cell configureSearchUserCellWithProfilePhoto:avatarURLObject fullName:firstname userName:username isFollowing:[user[@"following"] boolValue] userDict:self.users[indexPath.row] user:nil];
        }

        return cell;
    } else if (indexPath.section == storyIndex) {

        if (self.stories.count == 0) {
            return Nil;
        }

        if (indexPath.row == 3 && !_storyExtended) {
            [cell configureSearchSeeAllCellWithTitle:[NSString stringWithFormat:@"SEE ALL %lu STORIES", self.stories.count]];
            return cell;
        }

        if (indexPath.row == self.stories.count + 1 && !_storyExtended) {
            [cell configureEmptyCellSpace:NO];
            return cell;
        }

        NSDictionary *story = self.stories[indexPath.row];
        NSURL *photo;

        if ([story[@"thumbnails"] count] > 0) {
            NSString *urlString = story[@"thumbnails"][0][@"image"];
            if (urlString != nil) {
                photo = [NSURL URLWithString:urlString];
            }
        }

        NSString *title = @" ";
        if (story[@"title"] && ![story[@"title"] isEqual:[NSNull null]]) {
            title = story[@"title"];
        }

        [cell configureSearchStoryCellWithStoryPhoto:photo storyName:title];
        return cell;
    }

    if (indexPath.section == galleryIndex) {

        FRSGalleryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:galleryIdentifier];
        if (!cell) {
            cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:galleryIdentifier];
        }
        //        cell.delegate = self;
        cell.navigationController = self.navigationController;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.gallery = self.galleries[indexPath.row];

        __weak typeof(self) weakSelf = self;

        cell.shareBlock = ^void(NSArray *sharedContent) {
          [weakSelf showShareSheetWithContent:sharedContent];
        };

        cell.readMoreBlock = ^void(NSArray *sharedContent) {
          [self readMore:indexPath];
        };

        dispatch_async(dispatch_get_main_queue(), ^{
          [cell clearCell];
          [cell configureCell];
        });
        UITableViewCell *cellToReturn = (UITableViewCell *)cell;
        return cellToReturn;
    }

    return Nil;
}

- (void)reloadDataDelegate {
    [self reloadData];
    [self performSearchWithQuery:self.searchTextField.text];
}

- (void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [[[self.view window] rootViewController] presentViewController:activityController animated:YES completion:nil];
}

- (void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[self.galleries objectAtIndex:indexPath.row]];
    vc.shouldHaveBackButton = YES;

    self.navigationItem.title = @"";

    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == userIndex) {
        if (indexPath.row >= self.users.count) {
            return;
        }

        if (indexPath.row == 3 && !_userExtended) { // see all users cell
            _userExtended = YES;
            [tableView reloadData];

            return;
        }

        NSDictionary *user = self.users[indexPath.row];
        FRSUser *userObject = [FRSUser nonSavedUserWithProperties:user context:[[FRSAPIClient sharedClient] managedObjectContext]];
        FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUser:userObject];
        [self.navigationController pushViewController:controller animated:TRUE];

        //        self.shouldUpdateOnReturn = YES;
    }

    if (indexPath.section == storyIndex) {

        if (indexPath.row == 3 && !_storyExtended) { // see all stories cell

            _storyExtended = YES;
            [tableView reloadData];

            return;
        }

        NSDictionary *story = self.stories[indexPath.row];

        [self pushStoryView:story[@"id"] inRow:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end