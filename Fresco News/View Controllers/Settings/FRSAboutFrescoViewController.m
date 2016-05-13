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

@end

@implementation FRSAboutFrescoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.creditsArray = @[@"Philip Bernstein", @"Omar Elfanek", @"Imogen Olsen", @"Elmir Kõuliev", @"Daniel Sun"];
    
    [self configureUI];
}




#pragma mark - Interface

-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureNavigationBar];
    [self configureFrescoLogo];
    [self configureVersionHeader];
    [self configureCredits];
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
    versionLabel.text = @"Version 3.0";
    versionLabel.font = [UIFont notaBoldWithSize:17];
    versionLabel.textColor = [UIColor frescoDarkTextColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *buildLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -288/2, 139, 288, 16)];
    buildLabel.text = @"Build 420 • May 6, 2016";
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
    
    
    
    [self.view addSubview:creditsLabel];
    [self.view addSubview:creditsTableView];
}

-(void)configureSocialButtons {
    
    UIButton *twitter = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitter setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    
    
    
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
    NSLog(@"Share");
}








@end
