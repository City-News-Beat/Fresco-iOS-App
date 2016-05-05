//
//  FRSUploadViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/3/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadViewController.h"
#import "FRSAssignmentPickerTableViewCell.h"
#import "FRSAssignment.h"

@interface FRSUploadViewController ()

@property (strong, nonatomic) UIView *navigationBarView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *assignmentsArray;
@property (strong, nonatomic) UITextView *captionTextView;
@property (strong, nonatomic) UIView *captionContainer;
@property (strong, nonatomic) UIView *bottomContainer;
@property (strong, nonatomic) UILabel *placeholderLabel;

@end

@implementation FRSUploadViewController

static NSString * const cellIdentifier = @"assignment-cell";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}


-(void)configureUI {
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.navigationController.navigationBarHidden = YES;
    
    [self addNotifications];
    
    [self configureNavigationBar];
    [self configureScrollView];
    [self configureAssignments];
    [self configureTableView];
    [self configureTextView];
    [self configureBottomBar];
    
    self.tableView.tableFooterView = self.captionContainer;
    self.tableView.tableHeaderView = self.scrollView;
}


#pragma mark - Navigation Bar

-(void)configureNavigationBar {

    /* Configure sudo navigationBar */
        // Used UIView instead of UINavigationBar for increased flexibility when animating
    self.navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.navigationBarView.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:self.navigationBarView];
    
    /* Configure backButton */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(12, 30, 24, 24);
    [backButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    /* Configure squareButton */
    UIButton *squareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    squareButton.frame = CGRectMake(self.navigationBarView.frame.size.width-12-24, 30, 24, 24);
    [squareButton setImage:[UIImage imageNamed:@"square"] forState:UIControlStateNormal];
    [squareButton setTintColor:[UIColor whiteColor]];
    [squareButton addTarget:self action:@selector(square) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:squareButton];
    
    /* Configure titleLabel */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -66/2, 35, 66, 19)];
    [titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [titleLabel setText:@"GALLERY"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self.navigationBarView addSubview:titleLabel];
}

-(void)configureBottomBar {
    
    /* Configure bottom container */
    self.bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -44, self.view.frame.size.width, 44)];
    self.bottomContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.bottomContainer];
    
    UIView *bottomContainerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    bottomContainerLine.backgroundColor = [UIColor frescoShadowColor];
    [self.bottomContainer addSubview:bottomContainerLine];
    
    /* Configure bottom bar */
    //Configure Twitter post button
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitterButton addTarget:self action:@selector(postToTwitter) forControlEvents:UIControlEventTouchDown];
    UIImage *twitter = [[UIImage imageNamed:@"twitter-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [twitterButton setImage:twitter forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(16, 10, 24, 24);
    [self.bottomContainer addSubview:twitterButton];
    
    //Configure Facebook post button
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitterButton addTarget:self action:@selector(postToFacebook) forControlEvents:UIControlEventTouchDown];
    UIImage *facebook = [[UIImage imageNamed:@"facebook-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [facebookButton setImage:facebook forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(56, 10, 24, 24);
    [self.bottomContainer addSubview:facebookButton];
    
    //Configure anonymous posting button
    UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [anonymousButton addTarget:self action:@selector(postAnonymously) forControlEvents:UIControlEventTouchDown];
    UIImage *eye = [[UIImage imageNamed:@"eye-26"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [anonymousButton setImage:eye forState:UIControlStateNormal];
    anonymousButton.frame = CGRectMake(96, 10, 24, 24);
    [self.bottomContainer addSubview:anonymousButton];
    
    //Configure next button
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [sendButton setTintColor:[UIColor frescoLightTextColor]];
    sendButton.frame = CGRectMake(self.view.frame.size.width-64, 0, 64, 44);
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    sendButton.userInteractionEnabled = NO;
    [self.bottomContainer addSubview:sendButton];
}


#pragma mark - UIScrollView

-(void)configureScrollView {
    
    /* Height for scrollView */
    int height;
    if (IS_IPHONE_5) {
        height = 240;
    } else if (IS_IPHONE_6) {
        height = 280;
    } else if (IS_IPHONE_6_PLUS) {
        height = 310;
    }
    
    /* Configure scrollView */
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, height)];
    self.scrollView.delegate = self;
    [self.navigationBarView addSubview:self.scrollView];

    /* DEBUG */
    self.scrollView.backgroundColor = [UIColor redColor];
    self.scrollView.alpha = 0.1;
}


#pragma mark - UITableView

-(void)configureTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = YES;
    [self adjustTableViewFrame];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAssignmentPickerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    
    [self.tableView registerClass:[FRSAssignmentPickerTableViewCell self] forCellReuseIdentifier:cellIdentifier];
}

-(void)adjustTableViewFrame {
 
    NSInteger height = 88; //Count of submittable assignments * 44

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    switch (self.assignmentsArray.count) {
//        case 0:
//            return 0;
//            
//        default:
            return 3;
//    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSAssignmentPickerTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.row == 0) {
//        cell.isSelectedAssignment = YES;
//    }
    
    [cell configureCell];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FRSAssignment *assignment;
    
    FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier assignment:assignment];
    
    [cell configureCell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"SELECTED: %ld", indexPath.row);

}



#pragma mark - Text View

-(void)configureTextView {
    
    int textViewHeight = 200;
    
    self.captionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, textViewHeight + 16)];
    [self.view addSubview:self.captionContainer];
    
    self.captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, textViewHeight)];
    self.captionTextView.delegate = self;
    self.captionTextView.clipsToBounds = NO;
    self.captionTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.captionTextView.textColor = [UIColor frescoDarkTextColor];
    self.captionTextView.tintColor = [UIColor frescoOrangeColor];
    self.captionTextView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.captionContainer addSubview:self.captionTextView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-16, -16, self.view.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.captionTextView addSubview:line];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, 17)];
    self.placeholderLabel.text = @"What's happening?";
    self.placeholderLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.placeholderLabel.textColor = [UIColor frescoLightTextColor];
    [self.captionContainer addSubview:self.placeholderLabel];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) { //Check for spaces
        self.placeholderLabel.alpha = 1;
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeholderLabel.alpha = 0;
    
    return YES;
}

//-(void)textViewDidChange:(UITextView *)textView {
//
//    if (self.captionTextView.text.length == 0) {
//        self.captionTextView.textColor = [UIColor frescoLightTextColor];
//        self.captionTextView.text = @"What’s happening?";
//        [self.captionTextView resignFirstResponder];
//    }
//}

-(void)dismissKeyboard {
    
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - Keyboard

-(void)handleKeyboardWillShow:(NSNotification *)sender {
    
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomContainer.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    self.tableView.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
}

-(void)handleKeyboardWillHide:(NSNotification *)sender{
    
    self.bottomContainer.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableView.transform = CGAffineTransformMakeTranslation(0, 0);
}

#pragma mark - Assignments

-(void)configureAssignments {
    
    NSString *assignmentOne   = @"Student Health Fair @ 10 a.m. in Camden, New Jersey";
    NSString *assignmentTwo   = @"Alert! Police Activity in Oxnard";
    NSString *assignmentThree = @"Bernie Sanders Rally @ 10:30 a.m. next to UCI's Student Center";

    self.assignmentsArray = [[NSMutableArray alloc] initWithObjects:assignmentOne, assignmentTwo, assignmentThree, nil];
}

#pragma mark - Actions

/* Navigation bar*/
    //Back button action
-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

    //Next button action
-(void)send {
    //Send to Fresco
    //Post to selected social
    //Configure anonymity
}

    //Square button action
-(void)square {
    
}


/* Bottom Bar */
    //Post to Facebook
-(void)postToFacebook {
    
}

    //Post to Twitter
-(void)postToTwitter {
    
}

    //Post Anonymously
-(void)postAnonymously {
    
}


#pragma mark - Notifications

-(void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}


@end