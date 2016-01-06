//
//  FRSProfileViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSProfileViewController.h"

@interface FRSProfileViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIView *profileBG;
@property (strong, nonatomic) UIImageView *profileIV;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *bioLabel;

@property (strong, nonatomic) UIImageView *followersIV;
@property (strong, nonatomic) UILabel *followersLabel;

@property (strong, nonatomic) UIView *sectionView;
@property (strong, nonatomic) UIButton *feedButton;
@property (strong, nonatomic) UIButton *likesButton;

@end

@implementation FRSProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    // Do any additional setup after loading the view.
}

#pragma mark - UI Elements
-(void)configureUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureNavigationBar];
    [self configureScrollView];
    [self configureTopContainer];
}

-(void)configureNavigationBar{
    [super configureNavigationBar];
    self.navigationItem.title = @"@aesthetique";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bell-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(something)];
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pen-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(somethingone)];
    UIBarButtonItem *gearItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(somethingtwo)];
    editItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30);
    
    self.navigationItem.rightBarButtonItems = @[gearItem, editItem];
    
}

-(void)configureScrollView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height - 64)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.scrollView];
}

-(void)configureTopContainer{
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 269.5)];
    self.topContainer.backgroundColor = [UIColor frescoOrangeColor];
    [self.scrollView addSubview:self.topContainer];
    
    [self configureProfileImage];
    [self configureLabels];
    [self resizeTopContainer];
    [self configureSectionView];
    [self addBottomLineToView:self.topContainer];
}

-(void)configureProfileImage{
    self.profileBG = [[UIView alloc] initWithFrame:CGRectMake(16, 12, 96, 96)];
    [self.topContainer addSubview:self.profileBG];
    [self.profileBG addShadowWithColor:[UIColor frescoShadowColor] radius:3 offset:CGSizeMake(0, 2)];
    
    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileBG.frame.size.width, self.profileBG.frame.size.height)];
    self.profileIV.image = [UIImage imageNamed:@"kobe"];
    self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
    self.profileIV.layer.cornerRadius = self.profileIV.frame.size.width/2;
    [self.profileIV addBorderWithWidth:4 color:[UIColor whiteColor]];
    self.profileIV.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.profileIV.clipsToBounds = YES;
    [self.profileBG addSubview:self.profileIV];
    
    self.followersIV = [[UIImageView alloc] initWithFrame:CGRectMake(35, self.profileBG.frame.origin.y + self.profileBG.frame.size.height + 12, 24, 24)];
    self.followersIV.image = [UIImage imageNamed:@"followers-icon"];
    self.followersIV.contentMode = UIViewContentModeCenter;
    [self.topContainer addSubview:self.followersIV];
    
    self.followersLabel = [[UILabel alloc] init];
    self.followersLabel.text = @"1.5M";
    self.followersLabel.textColor = [UIColor whiteColor];
    self.followersLabel.font = [UIFont notaBoldWithSize:15];
    [self.followersLabel sizeToFit];
    self.followersLabel.frame = CGRectMake(self.followersIV.frame.origin.x + self.followersIV.frame.size.width + 7, self.followersIV.frame.origin.y, self.followersLabel.frame.size.width, self.followersIV.frame.size.height);
    [self.topContainer addSubview:self.followersLabel];
    
    
    
}

-(void)configureLabels{
    NSInteger origin = self.profileBG.frame.origin.x + self.profileBG.frame.size.width + 16;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.profileBG.frame.origin.y, self.view.frame.size.width - origin - 16, 22)];
    self.nameLabel.text = @"Kobe Bryant, the GOAT";
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont notaMediumWithSize:17];
    [self.topContainer addSubview:self.nameLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, self.nameLabel.frame.size.width, 14)];
    self.locationLabel.text = @"Los Angeles, California";
    self.locationLabel.textColor = [UIColor whiteColor];
    self.locationLabel.font = [UIFont systemFontOfSize:12 weight:-1];
    [self.topContainer addSubview:self.locationLabel];
    
    self.bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.locationLabel.frame.origin.y + self.locationLabel.frame.size.height + 6, self.nameLabel.frame.size.width, 0)];
    self.bioLabel.numberOfLines = 0;
    self.bioLabel.text = @"Yo, I'm Kobe Bryant. AKA the Black Mamba. Y'all need to bow down before my greatness. Also I like video games. Like 2K15. I pick the Lakers, and then I just play as myself and never pass the ball and score buckets, bc I'm fucking Kobe Bryant.";
    self.bioLabel.textColor = [UIColor whiteColor];
    self.bioLabel.font = [UIFont systemFontOfSize:15 weight:-1];
    [self.bioLabel sizeToFit];
    [self.topContainer addSubview:self.bioLabel];
}

-(void)resizeTopContainer{
    
    CGFloat height = MAX(self.bioLabel.frame.origin.y + self.bioLabel.frame.size.height + 6 + 43.5, 160 + 43.5);
    
    [self.topContainer setSizeWithSize:CGSizeMake(self.topContainer.frame.size.width, height)];
}

-(void)configureSectionView{
    self.sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topContainer.frame.size.height - 43.5, self.topContainer.frame.size.width, 43.5)];
    [self.scrollView addSubview:self.sectionView];
    
    self.feedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.sectionView.frame.size.width/2, self.sectionView.frame.size.height)];
    [self.feedButton setTitle:@"FEED" forState:UIControlStateNormal];
    [self.feedButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [self.feedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.feedButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.feedButton addTarget:self action:@selector(toggleSelectedTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.feedButton setSelected:YES];
    [self.sectionView addSubview:self.feedButton];
    
    self.likesButton = [[UIButton alloc] initWithFrame:CGRectOffset(self.feedButton.frame, self.feedButton.frame.size.width, 0)];
    [self.likesButton setTitle:@"LIKES" forState:UIControlStateNormal];
    [self.likesButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
    [self.likesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.likesButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.likesButton addTarget:self action:@selector(toggleSelectedTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.sectionView addSubview:self.likesButton];
}

-(void)addBottomLineToView:(UIView *)view{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [view addSubview:line];
}

-(void)toggleSelectedTab:(UIButton *)sender{
    
    if (sender.isSelected) return;
    
    [self.feedButton setSelected:!self.feedButton.isSelected];
    [self.likesButton setSelected:!self.likesButton.isSelected];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
