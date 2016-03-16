//
//  FRSProfileViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSProfileViewController.h"

//View Controllers
#import "FRSSettingsViewController.h"
#import "FRSFollowersViewController.h"
#import "FRSNavigationController.h"

#import "FRSGalleryCell.h"
#import "FRSDataManager.h"

#import "FRSBorderedImageView.h"

#import <MagicalRecord/MagicalRecord.h>

#import "DGElasticPullToRefresh.h"

@interface FRSProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

//@property (strong, nonatomic) UIScrollView *scrollView;


@property (strong, nonatomic) UIView *profileContainer;

@property (strong, nonatomic) UIView *profileBG;

//@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) FRSBorderedImageView *profileIV;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *bioLabel;

@property (strong, nonatomic) UIImageView *followersIV;
@property (strong, nonatomic) UILabel *followersLabel;

@property (strong, nonatomic) UIButton *followersButton;

@property (strong, nonatomic) UIView *sectionView;
@property (strong, nonatomic) UIButton *feedButton;
@property (strong, nonatomic) UIButton *likesButton;

@property (strong, nonatomic) NSArray *galleries;

@property (strong, nonatomic) UIView *whiteOverlay;
@property (strong, nonatomic) UIView *socialButtonContainer;
@property (strong, nonatomic) UIView *profileMaskView;

@property (nonatomic) BOOL overlayPresented;

@property (nonatomic) NSInteger count;

@end

@implementation FRSProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self fetchGalleries];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addStatusBarNotification];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeStatusBarNotification];
}

#pragma mark - Fetch Methods

-(void)fetchGalleries{
    [[FRSDataManager sharedManager] getGalleries:@{@"offset" : @0, @"hide" : @4, @"stories" : @"true"} shouldRefresh:YES withResponseBlock:^(NSArray* responseObject, NSError *error) {
        if (!responseObject.count){
            return;
        }
        
        NSMutableArray *mArr = [NSMutableArray new];
        
        NSArray *galleries = responseObject;
        for (NSDictionary *dict in galleries){
            FRSGallery *gallery = [FRSGallery MR_createEntity];
            [gallery configureWithDictionary:dict];
            [mArr addObject:gallery];
        }
        
        self.galleries = [mArr copy];
        [self.tableView reloadData];
    }];
}

#pragma mark - UI Elements
-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureNavigationBar];
    [self configureTableView];
    [self configurePullToRefresh];
    [self configureProfileSocialOverlay];
}

-(void)configurePullToRefresh{
    [super removeNavigationBarLine];
    
    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor frescoOrangeColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:2 actionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView dg_stopLoading];
        });
    } loadingView:loadingView];
    
    
    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
    
}

- (void)dealloc{
    [self.tableView dg_removePullToRefresh];
}

-(void)configureNavigationBar{
//    [super configureNavigationBar];
    [super removeNavigationBarLine];
    
    //self.navigationItem.title = @"@aesthetique";
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"@aesthetique";
    titleLabel.font = [UIFont fontWithName:@"Nota-Bold" size:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bell-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showNotifications)];
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pen-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showEditProfile)];
    UIBarButtonItem *gearItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    editItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30);
    
    self.navigationItem.rightBarButtonItems = @[gearItem, editItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)configureTableView{
    
    [self createProfileSection];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height - 64 - 49)];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

-(void)createProfileSection{
    self.profileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 269.5)];
    self.profileContainer.backgroundColor = [UIColor frescoOrangeColor];
    
    [self configureProfileImage];
    [self configureLabels];
    [self resizeProfileContainer];
}

-(void)configureProfileImage{
    self.profileBG = [[UIView alloc] initWithFrame:CGRectMake(16, 12, 96, 96)];
    [self.profileContainer addSubview:self.profileBG];
    [self.profileBG addShadowWithColor:[UIColor frescoShadowColor] radius:3 offset:CGSizeMake(0, 2)];
    
    self.profileIV = [[FRSBorderedImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileBG.frame.size.width, self.profileBG.frame.size.height) borderColor:[UIColor whiteColor] borderWidth:4];
    self.profileIV.image = [UIImage imageNamed:@"kobe"];
    self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
    self.profileIV.layer.cornerRadius = self.profileIV.frame.size.width/2;
    self.profileIV.clipsToBounds = YES;
    [self.profileBG addSubview:self.profileIV];
    
    self.followersIV = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 24, 24)];
    self.followersIV.image = [UIImage imageNamed:@"followers-icon"];
    self.followersIV.contentMode = UIViewContentModeCenter;
    self.followersIV.userInteractionEnabled = YES;
    
    self.followersLabel = [[UILabel alloc] init];
    self.followersLabel.text = @"1.5M";
    self.followersLabel.userInteractionEnabled = YES;
    self.followersLabel.textColor = [UIColor whiteColor];
    self.followersLabel.font = [UIFont notaBoldWithSize:15];
    [self.followersLabel sizeToFit];
    self.followersLabel.frame = CGRectMake(self.followersIV.frame.origin.x + self.followersIV.frame.size.width + 7, self.followersIV.frame.origin.y, self.followersLabel.frame.size.width, self.followersIV.frame.size.height);
    
    UIView *followersContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12 + 24 + self.followersLabel.frame.size.width + 7, 12 + 24)];
    followersContainer.center = self.profileBG.center;
    [followersContainer setOriginWithPoint:CGPointMake(followersContainer.frame.origin.x, self.profileBG.frame.origin.y + self.profileBG.frame.size.height + 6)];
    [followersContainer addSubview:self.followersIV];
    [followersContainer addSubview:self.followersLabel];
    [self.profileContainer addSubview:followersContainer];
    
    [followersContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers)]];
    
}

-(void)configureProfileSocialOverlay{

    self.whiteOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
    self.whiteOverlay.backgroundColor = [UIColor whiteColor];
    self.whiteOverlay.alpha = 1;
    [self.profileIV addSubview:self.whiteOverlay];
    
    UIButton *socialOverlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [socialOverlayButton addTarget:self action:@selector(presentSocialOverlay) forControlEvents:UIControlEventTouchUpInside];
    socialOverlayButton.frame = CGRectMake(16, 12, 96, 96);
    socialOverlayButton.layer.cornerRadius = 48;
    [self.profileContainer addSubview:socialOverlayButton];
    
    self.socialButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(16, 36, 64.5, 24)];
    self.socialButtonContainer.alpha = 1;
    [self.whiteOverlay addSubview:self.socialButtonContainer];
//    [self.whiteOverlay insertSubview:self.socialButtonContainer aboveSubview:self.view];

    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitterButton addTarget:self action:@selector(twitterTapped) forControlEvents:UIControlEventTouchDown];
    UIImage *twitter = [[UIImage imageNamed:@"twitter-icon-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [twitterButton setImage:twitter forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(0, 0, 24, 24);
    twitterButton.alpha = 1;
    [self.socialButtonContainer addSubview:twitterButton];
    
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [facebookButton addTarget:self action:@selector(facebookTapped) forControlEvents:UIControlEventTouchDown];
    UIImage *facebook = [[UIImage imageNamed:@"facebook-icon-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [facebookButton setImage:facebook forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(40, 0, 24, 24);
    facebookButton.alpha = 1;
    [self.socialButtonContainer addSubview:facebookButton];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gr];

    self.profileMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
    self.profileMaskView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    self.profileMaskView.layer.cornerRadius = 48;
    self.profileMaskView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.profileMaskView];
    self.whiteOverlay.layer.mask = self.profileMaskView.layer;

}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (!CGRectContainsPoint(self.profileIV.frame, point)) {
        [self dismissSocialOverlay];
    }
}

-(void)presentSocialOverlay{
    
    if (!self.overlayPresented) {
        
        //Set overlay presented state to prevent animating if double tapped
        self.overlayPresented = YES;
        
        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.profileMaskView.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:nil];
        
        //Set default transform
//        self.socialButtonContainer.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        
//        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
//            
//            self.socialButtonContainer.transform = CGAffineTransformMakeScale(1.05, 1.05);
//            self.socialButtonContainer.alpha = 1;
//            self.whiteOverlay.alpha = 1;
//            
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
//                
//                self.socialButtonContainer.transform = CGAffineTransformMakeScale(1, 1);
//                
//            } completion:nil];
//        }];
    }
}

-(void)dismissSocialOverlay{
    
    //Set overlay presented state to prevent animating if double tapped
    self.overlayPresented = NO;
    
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.profileMaskView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        
    } completion:nil];

//    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
//        
//        self.socialButtonContainer.alpha = 0;
//        self.socialButtonContainer.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
//        self.whiteOverlay.alpha = 0;
//        
//    } completion:nil];
    
}

-(void)configureLabels{
    NSInteger origin = self.profileBG.frame.origin.x + self.profileBG.frame.size.width + 16;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.profileBG.frame.origin.y, self.view.frame.size.width - origin - 16, 22)];
    self.nameLabel.text = @"Kobe Bryant";
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont notaMediumWithSize:17];
    [self.profileContainer addSubview:self.nameLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, self.nameLabel.frame.size.width, 14)];
    self.locationLabel.text = @"Los Angeles, California";
    self.locationLabel.textColor = [UIColor whiteColor];
    self.locationLabel.font = [UIFont systemFontOfSize:12 weight:-1];
    [self.profileContainer addSubview:self.locationLabel];
    
    self.bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.locationLabel.frame.origin.y + self.locationLabel.frame.size.height + 6, self.nameLabel.frame.size.width, 0)];
    self.bioLabel.numberOfLines = 0;
    self.bioLabel.text = @"Yo, I'm Kobe Bryant. AKA the Black Mamba. Y'all need to bow down before my greatness. Also I like video games. Like 2K15. I pick the Lakers, and then I just play as myself and never pass the ball and score buckets, bc I'm fucking Kobe Bryant.";
    self.bioLabel.textColor = [UIColor whiteColor];
    [self.bioLabel sizeToFit];
    [self.profileContainer addSubview:self.bioLabel];
}

-(void)resizeProfileContainer{
    
    CGFloat height = MAX(self.bioLabel.frame.origin.y + self.bioLabel.frame.size.height + 6, 160);
    
    [self.profileContainer setSizeWithSize:CGSizeMake(self.profileContainer.frame.size.width, height)];
}

-(void)configureSectionView{
    self.sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.sectionView.backgroundColor = [UIColor frescoOrangeColor];
    
    self.feedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.sectionView.frame.size.width/2, self.sectionView.frame.size.height)];
    [self.feedButton setTitle:@"FEED" forState:UIControlStateNormal];
    [self.feedButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.feedButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.feedButton addTarget:self action:@selector(handleFeedbackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.sectionView addSubview:self.feedButton];
    
    self.likesButton = [[UIButton alloc] initWithFrame:CGRectOffset(self.feedButton.frame, self.feedButton.frame.size.width, 0)];
    [self.likesButton setTitle:@"LIKES" forState:UIControlStateNormal];
    [self.likesButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    self.likesButton.alpha = 0.7;
    [self.likesButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.likesButton addTarget:self action:@selector(handleLikesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.sectionView addSubview:self.likesButton];
}

-(void)handleFeedbackButtonTapped{
    if (self.feedButton.alpha > 0.7) return; //The button is already selected
    
    self.feedButton.alpha = 1.0;
    self.likesButton.alpha = 0.7;
}

-(void)handleLikesButtonTapped{
    if (self.likesButton.alpha > 0.7) return; //The button is already selected
    
    self.likesButton.alpha = 1.0;
    self.feedButton.alpha = 0.7;
}

#pragma mark - UITableView Delegate & DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
    
    //We have two sections for our tableview. The first section holds the profile container and has a header height of 0.
    //The second section holds the feed/likes, and the header has the segmented tab and has a height of 44.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }
    else {
        return self.galleries.count;
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0;
    }
    else{
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return self.profileContainer.frame.size.height;
    }
    else {
//        return 600;
        if (!self.galleries.count) return 0;
        FRSGallery *gallery = self.galleries[indexPath.row];
        return [gallery heightForGallery];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    if (indexPath.section == 0){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profile-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
        if (!cell){
            cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section== 0){
        [cell addSubview:self.profileContainer];
    }
    else {
        FRSGalleryCell *galCell = (FRSGalleryCell *)cell;
        [galCell clearCell];
        
        galCell.gallery = self.galleries[indexPath.row];
        [galCell configureCell];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view;
    
    if (section == 0){
        view = [UIView new];
    }
    else if (section == 1){
        [self configureSectionView];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [view addSubview:self.sectionView];
        [view addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    }
    
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    [self dismissSocialOverlay];
    
    if (scrollView == self.tableView){
        [super determineScrollDirection:scrollView];
        
        if (self.scrollDirection == UIScrollViewScrollDirectionDown){
            if ([self.tableView.backgroundColor isEqual:[UIColor frescoBackgroundColorDark]]) return;
            self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
            [self.tableView dg_stopLoading];
            
        }
        else {
            if ([self.tableView.backgroundColor isEqual:[UIColor frescoOrangeColor]]) return;
            
            self.tableView.backgroundColor = [UIColor frescoOrangeColor];
        }
    }
}

#pragma mark - Navigation

-(void)showNotifications{
    
}

-(void)showSettings{
    self.navigationController.hidesBottomBarWhenPushed = YES;
    FRSSettingsViewController *settingsVC = [[FRSSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
    self.navigationItem.title = @"";
    [self hideTabBarAnimated:YES];
}

-(void)showEditProfile{
    
}

-(void)showFollowers{
    FRSFollowersViewController *vc = [[FRSFollowersViewController alloc] init];
    FRSNavigationController *nav = [[FRSNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Social Overlay Actions

-(void)twitterTapped{
    NSLog(@"twitterTapped");
}

-(void)facebookTapped{
    NSLog(@"facebookTapped");
}


@end
