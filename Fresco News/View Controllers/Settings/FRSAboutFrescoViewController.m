//
//  FRSAboutFrescoViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAboutFrescoViewController.h"

@interface FRSAboutFrescoViewController ()

@property (strong, nonatomic) NSArray *creditsArray;
@property (nonatomic) BOOL touchEnabled;

@end

@implementation FRSAboutFrescoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.creditsArray = @[@"Philip Bernstein", @"Omar Elfanek", @"Arthur De Araujo", @"Imogen Olsen", @"Elmir Kõuliev", @"Daniel Sun"];
    
    [self configureUI];
}


#pragma mark - Interface

-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureNavigationBar];
    [self configureFrescoLogo];
    [self configureVersionHeader];
    [self configureCredits];
    [self configureSocialButtons];
    [self configureLinks];
}


-(void)configureNavigationBar {
    
    [self configureBackButtonAnimated:NO];
    self.navigationItem.title = @"ABOUT FRESCO";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share-icon-light"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)configureFrescoLogo {
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wordmark"]];
    logoImageView.frame = CGRectMake(self.view.frame.size.width/2 -224/2, 32, 224, 78);
    [self.view addSubview:logoImageView];
    
}

-(void)configureVersionHeader {
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -288/2, 122, 288, 17)];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    versionLabel.text = [NSString stringWithFormat:@"Version %@", version];
    versionLabel.font = [UIFont notaBoldWithSize:17];
    versionLabel.textColor = [UIColor frescoDarkTextColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *buildLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -288/2, 139, 288, 16)];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *dateStr = [NSString stringWithUTF8String:__DATE__];
    buildLabel.text = [NSString stringWithFormat:@"Build %@ • %@",build,dateStr];
    buildLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    buildLabel.textColor = [UIColor frescoMediumTextColor];
    buildLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:versionLabel];
    [self.view addSubview:buildLabel];
}

-(void)configureCredits {
    
    UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -288/2, 171, 288, 15)];
    creditsLabel.text = @"Credits";
    creditsLabel.font = [UIFont notaBoldWithSize:15];
    creditsLabel.textColor = [UIColor frescoMediumTextColor];
    creditsLabel.textAlignment = NSTextAlignmentCenter;
    
    UITableView *creditsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -288/2, 188, 288, self.view.frame.size.height -64 -188 -116) style:UITableViewStylePlain];
    creditsTableView.delegate   = self;
    creditsTableView.dataSource = self;
    creditsTableView.rowHeight  = 20;
    creditsTableView.backgroundColor = [UIColor clearColor];
    creditsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    creditsTableView.separatorColor  = [UIColor clearColor];
    creditsTableView.scrollEnabled   = NO;
    creditsTableView.allowsSelection = NO;
    
    [self.view addSubview:creditsLabel];
    [self.view addSubview:creditsTableView];
}

-(void)configureSocialButtons {
    
    UIView *socialContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -144/2, self.view.frame.size.height -92 -24 -64, 144, 24)];
    [self.view addSubview:socialContainer];
    
    UIButton *twitter = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitter setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateNormal];
    [twitter setTintColor:[UIColor colorWithRed:0.333 green:0.675 blue:0.933 alpha:1]]; /* twitter #55acee */
    twitter.frame = CGRectMake(0, 0, 24, 24);
    [twitter addTarget:self action:@selector(twitter) forControlEvents:UIControlEventTouchUpInside];
    [socialContainer addSubview:twitter];
    
    UIButton *facebook = [UIButton buttonWithType:UIButtonTypeSystem];
    [facebook setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateNormal];
    [facebook setTintColor:[UIColor colorWithRed:0.231 green:0.349 blue:0.596 alpha:1]]; /* facebook #3b5998 */
    facebook.frame = CGRectMake(24+16, 0, 24, 24);
    [facebook addTarget:self action:@selector(facebook) forControlEvents:UIControlEventTouchUpInside];
    [socialContainer addSubview:facebook];
    
    UIButton *instagram = [UIButton buttonWithType:UIButtonTypeSystem];
    [instagram setImage:[UIImage imageNamed:@"social-instagram"] forState:UIControlStateNormal];
    [instagram setTintColor:[UIColor colorWithRed:0.247 green:0.447 blue:0.608 alpha:1]]; /* instagram #3f729b */
    instagram.frame = CGRectMake((24+16)*2, 0, 24, 24);
    [instagram addTarget:self action:@selector(instagram) forControlEvents:UIControlEventTouchUpInside];
    [socialContainer addSubview:instagram];
    
    UIButton *tumblr = [UIButton buttonWithType:UIButtonTypeSystem];
    [tumblr setImage:[UIImage imageNamed:@"social-tumblr"] forState:UIControlStateNormal];
    [tumblr setTintColor:[UIColor colorWithRed:0.196 green:0.275 blue:0.361 alpha:1]]; /* tumblr #32465c */
    tumblr.frame = CGRectMake((24+16)*3, 0, 24, 24);
    [tumblr addTarget:self action:@selector(tumblr) forControlEvents:UIControlEventTouchUpInside];
    [socialContainer addSubview:tumblr];
}

-(void)configureLinks {
    
    UIButton *homepage = [UIButton buttonWithType:UIButtonTypeSystem];
    homepage.frame = CGRectMake(self.view.frame.size.width/2 -119/2, self.view.frame.size.height -64 -56 -20, 119, 20);
    [homepage setTitle:@"fresconews.com" forState:UIControlStateNormal];
    [homepage.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
    [homepage setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [homepage addTarget:self action:@selector(homepage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:homepage];

    UIButton *terms = [UIButton buttonWithType:UIButtonTypeSystem];
    terms.frame = CGRectMake(self.view.frame.size.width/2 -239/2, self.view.frame.size.height -64 -24 -20, 239, 20);
    [terms setTitle:@"Terms of Service • Privacy Policy" forState:UIControlStateNormal];
    [terms.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
    [terms setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [terms addTarget:self action:@selector(terms) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:terms];

}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.creditsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"name-cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"name-cell"];
    }
    
    NSString *cellValue = [NSString stringWithFormat:@"%@", [self.creditsArray objectAtIndex:indexPath.row]];
    
    cell.textLabel.text = cellValue;
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    cell.textLabel.textColor = [UIColor frescoDarkTextColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Actions

-(void)share {
    NSLog(@"share");
}

-(void)twitter {
    [self openLink:@"https://twitter.com/fresconews"];
}

-(void)facebook {
    [self openLink:@"https://www.facebook.com/fresconews"];
}

-(void)instagram {
    [self openLink:@"https://www.instagram.com/fresconews"];
}

-(void)tumblr {
    [self openLink:@"http://fresconews.tumblr.com"];
}

-(void)homepage {
    [self openLink:@"https://fresconews.com"];
}

-(void)terms {
    [self openLink:@"https://fresconews.com/legal"];
}

-(void)openLink:(NSString *)link {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}


#pragma mark - 3D Touch


@end
