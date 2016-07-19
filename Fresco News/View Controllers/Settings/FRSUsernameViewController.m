//
//  FRSUsernameTableViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUsernameViewController.h"
#import "FRSAPIClient.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "FRSAppDelegate.h"

@interface FRSUsernameViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) FRSTableViewCell *cell;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) UIImageView *usernameCheckIV;

@end

@implementation FRSUsernameViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}

-(void)configureTableView{
    self.title = @"USERNAME";
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier;
    self.cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (self.cell == nil) {
        self.cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([self.cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self.cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([self.cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return self.cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell = self.cell;
    
    switch (indexPath.row) {
        case 0:
            switch (indexPath.section) {
                case 0:
                    [cell configureEditableCellWithDefaultText:@"New username" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.textField.delegate = self;
                    [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
                    
                    self.usernameCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-green"]];
                    self.usernameCheckIV.frame = CGRectMake(cell.textField.frame.size.width - 24, 10, 24, 24);
                    self.usernameCheckIV.alpha = 0;
                    [cell.textField addSubview:self.usernameCheckIV];
                    
                    break;
                default:
                    break;
            }
            break;
        case 1:
            [cell configureCellWithRightAlignedButtonTitle:@"SAVE USERNAME" withWidth:142 withColor:[UIColor frescoLightTextColor]];
            [cell.rightAlignedButton addTarget:self action:@selector(saveUsername) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
            break;
            
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    
    if ([textField.text isEqualToString:@""] || textField.text == nil) {
        self.usernameCheckIV.alpha = 0;
    }
    
    self.username = textField.text;
    [self checkUsername];
    
    //Set max length to 40
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 40;
    
    return YES;
}

-(void)saveUsername {
    
    NSDictionary *digestion = @{@"username" : self.username};
    
    
    [[FRSAPIClient sharedClient] updateUserWithDigestion:digestion completion:^(id responseObject, NSError *error) {
        NSLog(@"RESPONSE: %@ \n ERROR: %@", responseObject, error);
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate reloadUser];
    }];
    
    [self popViewController];
}

-(void)checkUsername {

    NSLog(@"SAVE USERNAME");
    
    if ([self.username isEqualToString:@""] || self.username == nil) {
        self.usernameCheckIV.alpha = 0;
        return;
    }
    
    [[FRSAPIClient sharedClient] checkUsername:self.username completion:^(id responseObject, NSError *error) {
        
        NSLog(@"RESPONSE OBJECT: %@", responseObject);
        NSLog(@"ERROR: %@", error);
        
        if ([error.userInfo[@"NSLocalizedDescription"][@"type"] isEqualToString:@"not_found"]) {
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
        } else {
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:YES];
        }
    }];
}

-(void)animateUsernameCheckImageView:(UIImageView *)imageView animateIn:(BOOL)animateIn success:(BOOL)success {
    
    if ([self.username isEqualToString:@""] || self.username == nil) {
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = NO;
        self.usernameCheckIV.alpha = 0;
        return;
    }
    
    if(!success) {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-green"];
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = YES;
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = NO;
    }
    
    if (animateIn) {
        if (self.usernameCheckIV.alpha == 0) {
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.usernameCheckIV.alpha = 0;
            self.usernameCheckIV.alpha = 1;
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1, 1);
        }
    } else {
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
        self.usernameCheckIV.alpha = 0;
    }
}












@end
