//
//  FRSStoryDetailViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 3/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryDetailViewController.h"
#import "FRSGalleryTableViewCell.h"
#import "MagicalRecord.h"
#import "FRSStory+CoreDataProperties.h"
#import "DGElasticPullToRefresh.h"
#import "Haneke.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSStoryManager.h"

@interface FRSStoryDetailViewController () <UINavigationBarDelegate>

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) UIView *headerContainer;
@property BOOL didConfigureHeader;
@property BOOL didLoadOnce;

@end

@implementation FRSStoryDetailViewController
@synthesize stories = _stories, story = _story, navigationController;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureSpinner];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];

    NSString *openedFrom = @"";

    if (self.isComingFromNotification) {
        openedFrom = @"push";
    } else {
        openedFrom = @"stories";
    }

    [FRSTracker track:galleryOpenedFromStories
           parameters:@{ @"story_id" : (self.story.uid != nil) ? self.story.uid : @"",
                         @"opened_from" : openedFrom }];
}

- (void)configureWithGalleries:(NSArray *)galleries {
    self.stories = [[NSMutableArray alloc] init];

    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *galleriesArray = galleries;

    for (NSDictionary *gallery in galleriesArray) {
        FRSGallery *galleryObject = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:delegate.managedObjectContext];
        [galleryObject configureWithDictionary:gallery context:delegate.managedObjectContext];
        [self.stories addObject:galleryObject];

        //Loop is finished
        if (galleriesArray.count == self.stories.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [self.galleriesTable reloadData];
              [self.loadingView stopLoading];
              [self.loadingView removeFromSuperview];
              self.loadingView.alpha = 0;
            });
        };
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeStatusBarNotification];
    [self pausePlayers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [FRSTracker screen:@"Story Detail"];

    [self setupTableView];
    if (self.story.caption != nil && ![self.story.caption isEqualToString:@""]) {
        [self configureCaptionHeader];
    }
    [self configureNavigationBar];
    [self addStatusBarNotification];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.galleriesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.galleriesTable.frame.size.width, 1)];
    self.galleriesTable.tableFooterView.backgroundColor = [UIColor clearColor];
    
    [self.galleriesTable reloadData];
    
    
    if (self.didLoadOnce) {
        [self reloadData];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.didLoadOnce = YES;
}
- (void)configureCaptionHeader {
    self.didConfigureHeader = YES;

    self.headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)]; // Height is calculated later
    self.headerContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.headerContainer];

    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 24, 24)];
    avatar.backgroundColor = [UIColor frescoLightTextColor];
    //set image
    avatar.layer.cornerRadius = 12;
    avatar.clipsToBounds = YES;
    avatar.layer.masksToBounds = YES;
    [self.headerContainer addSubview:avatar];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 14, [UIScreen mainScreen].bounds.size.width - 80, 22)];
    nameLabel.font = [UIFont notaMediumWithSize:17];
    nameLabel.textColor = [UIColor frescoDarkTextColor];
    nameLabel.text = [[_story creator] firstName];

    [self.headerContainer addSubview:nameLabel];

    if ([self.story curatorDict]) {
        nameLabel.text = [[self story] curatorDict][@"full_name"];
        [avatar hnk_setImageFromURL:[NSURL URLWithString:[[self story] curatorDict][@"avatar"]]];
    } else {
        nameLabel.text = @"Fresco News";
        avatar.alpha = 0;
        nameLabel.transform = CGAffineTransformMakeTranslation(-32, 0);
    }

    UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, [UIScreen mainScreen].bounds.size.width - 16, 14)];
    timestampLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    timestampLabel.textColor = [UIColor frescoMediumTextColor];
    timestampLabel.textAlignment = NSTextAlignmentRight;
    timestampLabel.text = [FRSDateFormatter timestampStringFromDate:[_story editedDate]];
    [self.headerContainer addSubview:timestampLabel];

    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 48, [UIScreen mainScreen].bounds.size.width - 32, 20)];
    captionLabel.textColor = [UIColor frescoDarkTextColor];
    captionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    captionLabel.text = _story.caption;
    captionLabel.numberOfLines = 0;
    [self.headerContainer addSubview:captionLabel];
    [captionLabel sizeToFit];

    UIView *bottomGap = [[UIView alloc] initWithFrame:CGRectMake(0, captionLabel.frame.size.height + 60, self.view.frame.size.width, 12)];
    bottomGap.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.headerContainer addSubview:bottomGap];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [bottomGap addSubview:line];

    self.headerContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, captionLabel.frame.size.height + 72);

    self.galleriesTable.tableHeaderView = self.headerContainer;
}

- (void)setupTableView {
    self.galleriesTable.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.galleriesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.galleriesTable.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.galleriesTable registerNib:[UINib nibWithNibName:@"FRSGalleryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:galleryCellIdentifier];
}

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    if (self.story.title) {
        label.text = [self.story.title uppercaseString];
    } else if (self.title) {
        label.text = [self.title uppercaseString];
    }
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];

    [self.navigationItem setTitleView:label];
}

- (void)dismissDetail {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stories.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRSGalleryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:galleryCellIdentifier];
    cell.navigationController = self.navigationController;
    cell.delegate = self;

    return cell;
}

- (void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[self.stories objectAtIndex:indexPath.row]];

    [vc configureBackButtonAnimated:YES];
    vc.openedFrom = @"stories";

    self.navigationItem.title = @"";
    [self.navigationController pushViewController:vc animated:YES];
    [self hideTabBarAnimated:YES];
}

- (void)playerWillPlay:(AVPlayer *)play {
    for (UITableView *tableView in @[ self.galleriesTable ]) {
        for (FRSGalleryTableViewCell *cell in [tableView visibleCells]) {
            for (FRSPlayer *player in cell.galleryView.players) {
                if (player != play && [[player class] isSubclassOfClass:[FRSPlayer class]]) {
                    [player pause];
                }
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.galleriesTable) {
        NSArray *visibleCells = [self.galleriesTable visibleCells];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          BOOL taken = FALSE;

          for (FRSGalleryTableViewCell *cell in visibleCells) {

              if (cell.frame.origin.y - self.galleriesTable.contentOffset.y < 300 && cell.frame.origin.y - self.galleriesTable.contentOffset.y > 100) {

                  if (!taken) {
                      [cell play];
                      taken = TRUE;
                  } else {
                      [cell pause];
                  }
              }
          }
        });
    }
}

- (void)viewDidLayoutSubviews {
    if ([self.galleriesTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.galleriesTable setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([self.galleriesTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.galleriesTable setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryTableViewCell class]]) {
        return;
    }

    if (cell.gallery == self.stories[indexPath.row]) {
        return;
    }

    cell.gallery = self.stories[indexPath.row];

    dispatch_async(dispatch_get_main_queue(), ^{
      [cell configureCell];
    });

    __weak typeof(self) weakSelf = self;

    cell.shareBlock = ^void(NSArray *sharedContent) {
      [weakSelf showShareSheetWithContent:sharedContent];
    };

    cell.readMoreBlock = ^void(NSArray *sharedContent) {
      [weakSelf readMore:indexPath];
    };
}

- (void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
    NSString *url = content[0];
    url = [[url componentsSeparatedByString:@"/"] lastObject];
    [FRSTracker track:galleryShared
           parameters:@{ @"gallery_id" : url,
                         @"shared_from" : @"story" }];
}

- (void)reloadData {
    [self fetchGalleries];
}

- (void)fetchGalleries {
    
    if (!self.stories) { // This property is misnamed. Should be galleries.
        self.stories = [[NSMutableArray alloc] init];
    }

    [[FRSStoryManager sharedInstance] fetchGalleriesInStory:self.story.uid
                                                 completion:^(NSArray *galleries, NSError *error) {

                                                   if (self.didLoadOnce) {
                                                       self.stories = [[NSMutableArray alloc] init]; // Clear array before adding new objects if view has already loaded. (ex) Read more on gallery and return to view.
                                                   }
                                                     
                                                   [self.loadingView stopLoading];
                                                   [self.loadingView removeFromSuperview];
                                                   self.loadingView.alpha = 0;

                                                   if (error) {
                                                       return;
                                                   }

                                                   FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                   NSArray *galleriesArray = galleries;

                                                   for (NSDictionary *gallery in galleriesArray) {
                                                       FRSGallery *galleryObject = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:delegate.managedObjectContext];
                                                       [galleryObject configureWithDictionary:gallery context:delegate.managedObjectContext];
                                                       [self.stories addObject:galleryObject];
                                                   }

                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self.galleriesTable reloadData];
                                                   });
                                                 }];
}

- (void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification {
    NSArray *filteredArray = [self.stories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];

    if (!filteredArray.count) {
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.stories.count) {
        return 0;
    }

    FRSGallery *gallery = [self.stories objectAtIndex:indexPath.row];
    return [gallery heightForGallery];
}

- (void)followStory {
}

- (void)scrollToGalleryIndex:(NSInteger)index {
}

- (void)configureSpinner {
    if (self.loadingView) {
        return;
    }

    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 10, [UIScreen mainScreen].bounds.size.height / 2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.galleriesTable addSubview:self.loadingView];
}

#pragma mark - Status Bar

- (void)statusBarTappedAction:(NSNotification *)notification {
    if (self.galleriesTable.contentOffset.y >= 0) {
        [self.galleriesTable setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)addStatusBarNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:kStatusBarTappedNotification
                                               object:nil];
}

- (void)removeStatusBarNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)pausePlayers {
    for (UITableView *tableView in @[ self.galleriesTable ]) {
        for (FRSGalleryTableViewCell *cell in [tableView visibleCells]) {
            for (FRSPlayer *player in cell.galleryView.players) {
                if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
                    [player pause];
                }
            }
        }
    }
}

@end
