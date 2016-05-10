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
@property (strong, nonatomic) UITableView *assignmentsTableView;
@property (strong, nonatomic) UITableView *galleryTableView;
@property (strong, nonatomic) NSArray *assignmentsArray;
@property (strong, nonatomic) UITextView *captionTextView;
@property (strong, nonatomic) UIView *captionContainer;
@property (strong, nonatomic) UIView *bottomContainer;
@property (strong, nonatomic) UILabel *placeholderLabel;

@property (strong, nonatomic) FRSAssignment *selectedAssignment;

@end

@implementation FRSUploadViewController

static NSString * const cellIdentifier = @"assignment-cell";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self checkButtonStates];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


-(void)configureUI {
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self addObservers];
    
    [self configureScrollView];
    [self configureGalleryTableView];
    [self configureNavigationBar];
    [self configureAssignments];
    [self configureAssignmentsTableView];
    [self configureTextView];
    [self configureBottomBar];

}

-(void)checkButtonStates {


    
    
    
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
    
    
    self.navigationBarView.alpha = 0;
    titleLabel.alpha = 0;
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
    self.twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.twitterButton addTarget:self action:@selector(postToTwitter:) forControlEvents:UIControlEventTouchDown];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter-icon-filled"] forState:UIControlStateSelected];
    self.twitterButton.frame = CGRectMake(16, 10, 24, 24);
    [self.bottomContainer addSubview:self.twitterButton];
    
    //Configure Facebook post button
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookButton addTarget:self action:@selector(postToFacebook:) forControlEvents:UIControlEventTouchDown];
    [self.facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [self.facebookButton setImage:[UIImage imageNamed:@"facebook-icon-filled"] forState:UIControlStateSelected];
    self.facebookButton.frame = CGRectMake(56, 10, 24, 24);
    [self.bottomContainer addSubview:self.facebookButton];
    
    //Configure anonymous posting button
    self.anonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.anonButton addTarget:self action:@selector(postAnonymously:) forControlEvents:UIControlEventTouchDown];
    [self.anonButton setImage:[UIImage imageNamed:@"eye-26"] forState:UIControlStateNormal];
    [self.anonButton setImage:[UIImage imageNamed:@"eye-filled"] forState:UIControlStateSelected];
    self.anonButton.frame = CGRectMake(96, 10, 24, 24);
    [self.bottomContainer addSubview:self.anonButton];
    
    //Configure anonymous label (default alpha = 0)
    self.anonLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 15, 83, 17)];
    self.anonLabel.text = @"ANONYMOUS";
    self.anonLabel.font = [UIFont notaBoldWithSize:15];
    self.anonLabel.textColor = [UIColor frescoOrangeColor];
    self.anonLabel.alpha = 0;
    [self.bottomContainer addSubview:self.anonLabel];
    
    //Configure next button
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem]; //Should be green when valid
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}


#pragma mark - UITableView

-(void)configureGalleryTableView {
    
    /* Height for galleryTableView */
    int height;
    if (IS_IPHONE_5) {
        height = 240;
    } else if (IS_IPHONE_6) {
        height = 280;
    } else if (IS_IPHONE_6_PLUS) {
        height = 310;
    }
    
    /* Configure galleryTableView */
    self.galleryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [self.scrollView addSubview:self.galleryTableView];
    
    /* DEBUG */
    self.galleryTableView.backgroundColor = [UIColor blueColor];
    self.galleryTableView.alpha = 0.1;
}

-(void)configureAssignmentsTableView {
    
    self.assignmentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryTableView.frame.size.height, self.view.frame.size.width, self.assignmentsArray.count *44)];
    self.assignmentsTableView.scrollEnabled = NO;
    self.assignmentsTableView.delegate = self;
    self.assignmentsTableView.dataSource = self;
    self.assignmentsTableView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.assignmentsTableView.showsVerticalScrollIndicator = NO;
//    self.assignmentsTableView.delaysContentTouches = NO;
    self.assignmentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self adjustTableViewFrame];
    [self.view addSubview:self.assignmentsTableView];
}

-(void)adjustTableViewFrame {

    NSInteger height = self.assignmentsArray.count * 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"self.assignmentsArray.count = %ld", self.assignmentsArray.count);
    
    switch (self.assignmentsArray.count) {
        case 0:
            return 3;
            
        default:
            return self.assignmentsArray.count;
    }
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
    
    FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:assignment];
    
    [cell configureCell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    FRSAssignmentPickerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell.isSelectedAssignment){
        cell.isSelectedAssignment = NO;
        self.selectedAssignment = nil;
    }
    else {
        [self resetOtherCells];
        cell.isSelectedAssignment = YES;
        self.selectedAssignment = cell.assignment;
    }
    
    [cell toggleImage];
}

-(void)resetOtherCells {
    for (NSInteger i = 0; i < self.assignmentsArray.count + 1; i++){
        FRSAssignmentPickerTableViewCell *cell = [self.assignmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedAssignment = NO;
        [cell toggleImage];
    }
}

#pragma mark - Text View

-(void)configureTextView {
    
    NSInteger textViewHeight = 200;
    
    self.captionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.galleryTableView.frame.size.height + self.assignmentsTableView.frame.size.height, self.view.frame.size.width, textViewHeight + 16)];
    [self.scrollView addSubview:self.captionContainer];
    
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

-(void)dismissKeyboard {
    
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - Keyboard

-(void)handleKeyboardWillShow:(NSNotification *)sender {
    
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomContainer.transform      = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    self.scrollView.transform           = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    self.assignmentsTableView.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
}

-(void)handleKeyboardWillHide:(NSNotification *)sender{
    
    self.bottomContainer.transform      = CGAffineTransformMakeTranslation(0, 0);
    self.scrollView.transform           = CGAffineTransformMakeTranslation(0, 0);
    self.assignmentsTableView.transform = CGAffineTransformMakeTranslation(0, 0);
}

#pragma mark - Assignments

-(void)configureAssignments {
    FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(expirationDate >= %@)", [NSDate date]];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSAssignment"];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    self.assignmentsArray = [NSMutableArray arrayWithArray:stored];
    
    self.assignmentsArray = @[@"one", @"two", @"three"];
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
-(void)postToFacebook:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebook-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

    //Post to Twitter
-(void)postToTwitter:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitter-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

    //Post Anonymously
-(void)postAnonymously:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"anon-tapped-uploadvc" object:self];
    
    [self updateStateForButton:sender];
}

-(void)updateStateForButton:(UIButton *)button {
    
    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }
    
    /* Check for self.anonButton to change associated label */
    if (button == self.anonButton && self.anonButton.selected) {
        self.anonLabel.alpha = 1;
    } else if (button == self.anonButton){
        self.anonLabel.alpha = 0;
    }
}

#pragma mark - NSNotification Center

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)addObservers {
    
    /* Bottom bar notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"anon-tapped-filevc"     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"twitter-tapped-filevc"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"facebook-tapped-filevc" object:nil];
    
    /* Keyboard notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}


-(void)receiveNotifications:(NSNotification *)notification {
    
    NSString *notif = [notification name];
    
    if ([notif isEqualToString:@"twitter-tapped-filevc"]) {
        
        [self updateStateForButton:self.twitterButton];
        
    } else if ([notif isEqualToString:@"facebook-tapped-filevc"]) {
        
        [self updateStateForButton:self.facebookButton];
        
    } else if ([notif isEqualToString:@"anon-tapped-filevc"]) {
        
        [self updateStateForButton:self.anonButton];
    }
}


@end