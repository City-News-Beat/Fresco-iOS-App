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
#import "FRSAlertView.h"

@interface FRSUsernameViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FRSAlertViewDelegate>

@property (strong, nonatomic) FRSTableViewCell *cell;
@property (strong, nonatomic) FRSAlertView *alert;
@property (strong, nonatomic) UIImageView *usernameCheckIV;
@property (strong, nonatomic) UIImageView *errorImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSTimer *usernameTimer;

@property (nonatomic) BOOL usernameTaken;



@end


@implementation FRSUsernameViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopUsernameTimer];
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


#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    self.cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    self.cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell = self.cell;
    
    switch (indexPath.row) {
        case 0:
            switch (indexPath.section) {
                case 0:
                    [cell configureEditableCellWithDefaultText:@"New username" withTopSeperator:YES withBottomSeperator:NO isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.textField.delegate = self;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
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
            [cell configureEditableCellWithDefaultText:@"Password" withTopSeperator:YES withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeDefault];
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
            break;
        case 2:
            [cell configureCellWithRightAlignedButtonTitle:@"SAVE USERNAME" withWidth:142 withColor:[UIColor frescoLightTextColor]];
            [cell.rightAlignedButton addTarget:self action:@selector(saveUsername) forControlEvents:UIControlEventTouchUpInside];
            break;
            
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}



#pragma mark - UITextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    
    if ([self isValidPassword:self.password] && self.usernameTaken) {
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = YES;
    }
    
    if (textField.isSecureTextEntry) {
        self.password = textField.text;
        NSLog(@"PASSWORD: %@", textField.text);
        return YES;
    }
    
    NSLog(@"USERNAME: %@", textField.text);
    if ([textField.text isEqualToString:@""] || textField.text == nil) {
        self.usernameCheckIV.alpha = 0;
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = NO;
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
    }
    
    self.username = textField.text;
    if ([self isValidUsername:self.username]) {
        [self checkUsername];
    } else {
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = NO;
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
    }
    
    //Set max length to 40
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 40;
    
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.isSecureTextEntry) {
        if (self.errorImageView) {
            textField.text = 0;
            self.errorImageView.alpha = 0;
            self.errorImageView = nil;
            [self.errorImageView removeFromSuperview];
        }
    }
}

-(void)addErrorToView {
    
    if (!self.errorImageView) {
        self.errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.errorImageView.frame = CGRectMake(self.view.frame.size.width - 34, 55, 24, 24);
        self.errorImageView.alpha = 1; // 0 when animating
        [self.view addSubview:self.errorImageView];
    }
}


#pragma mark - Actions

-(void)saveUsername {
    
    [self.view endEditing:YES];
    
    NSDictionary *digestion = @{@"username" : self.username, @"verify_password" : self.password};
    
    [[FRSAPIClient sharedClient] updateUserWithDigestion:digestion completion:^(id responseObject, NSError *error) {
        NSLog(@"RESPONSE: %@ \n ERROR: %@", responseObject, error);
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate reloadUser];
        
        
        if (error.code == -1009) {
            NSLog(@"Unable to connect.");
            if (!self.alert) {
                self.alert = [[FRSAlertView alloc] initWithTitle:@"NO CONNECTION" message:@"Please check your internet connection." actionTitle:@"SETTINGS" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                [self.alert show];
            }
            return;
        }
        
        NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
        NSInteger responseCode = response.statusCode;
        NSLog(@"ERROR: %ld", (long)responseCode);
        
        if (responseCode >= 400 && responseCode < 500) {
            // 400 level, client
            if (responseCode == 403) {
                
                [self addErrorToView];
                
            } else {
                if (!self.alert) {
                    self.alert = [[FRSAlertView alloc] initWithTitle:@"NO CONNECTION" message:@"Please check your internet connection." actionTitle:@"SETTINGS" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                    [self.alert show];
                    [self.cell.textField resignFirstResponder];
                }
                return;
            }
        }
        else if (responseCode >= 500 && responseCode < 600) {
            // 500 level, server
            if (!self.alert) {
                self.alert = [[FRSAlertView alloc] initWithTitle:@"NO CONNECTION" message:@"Please check your internet connection." actionTitle:@"SETTINGS" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                [self.alert show];
                [self.cell.textField resignFirstResponder];
            }

            return;
        }
        
        
        
        
        if (!error) {
            [self popViewController];
        }
        
    }];
    
    FRSUser *userToUpdate = [[FRSAPIClient sharedClient] authenticatedUser];
    userToUpdate.username = self.username;
    [[[FRSAPIClient sharedClient] managedObjectContext] save:Nil];
}


-(void)checkUsername {    
    
    if (![self isValidUsername:self.username]) {
        return;
    }
    
    NSRange whiteSpaceRange = [self.username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self.username isEqualToString:@""] || self.username == nil || whiteSpaceRange.location != NSNotFound || [self stringContainsEmoji:self.username]) {
        self.usernameCheckIV.alpha = 0;
        return;
    }
    
    [self startUsernameTimer];
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
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
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



#pragma mark - Username Timer

-(void)startUsernameTimer {
    if (!self.usernameTimer) {
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(usernameTimerFired) userInfo:nil repeats:YES];
    }
}


-(void)stopUsernameTimer {
    if ([self.usernameTimer isValid]) {
        [self.usernameTimer invalidate];
    }
    
    self.usernameTimer = nil;
}


-(void)usernameTimerFired {
    
    if (![self isValidUsername:self.username]) {
        return;
    }
    
    NSRange whiteSpaceRange = [self.username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self.username isEqualToString:@""] || self.username == nil || whiteSpaceRange.location != NSNotFound || [self stringContainsEmoji:self.username]) {
        self.usernameCheckIV.alpha = 0;
        return;
    }
    
    // Check for emoji and error
    if ([self stringContainsEmoji:[self.cell.textField.text substringFromIndex:1]]){
        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
        return;
    }
    
    if (![self stringContainsEmoji:self.cell.textField.text]) {
        
        if ((![self.cell.textField.text isEqualToString:@""])) {
            
            [[FRSAPIClient sharedClient] checkUsername:self.username completion:^(id responseObject, NSError *error) {
                
                    if (!error && responseObject) {
                        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:YES];
                        self.usernameTaken = NO;
                        [self stopUsernameTimer];
                        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
                        self.cell.rightAlignedButton.userInteractionEnabled = NO;
                    } else if (error.code == -1009){
                        if (!self.alert) {
                            self.alert = [[FRSAlertView alloc] initWithTitle:@"NO CONNECTION" message:@"Please check your internet connection." actionTitle:@"SETTINGS" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                            [self.alert show];
                            [self.cell.textField resignFirstResponder];
                        }
                    } else {
                        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
                        self.usernameTaken = YES;
                        [self stopUsernameTimer];
                    }
            }];
        }
    }
}



#pragma mark - Validators

-(void)checkPassword {
    if ([self isValidPassword:self.password]) {
        
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = YES;
    }
}


-(BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}


-(BOOL)isValidPassword:(NSString *)password {
    
    if (password.length < 7) {
        return NO;
    }
    
    return YES;
}


-(BOOL)isValidUsername:(NSString *)username {
    
    if ([self stringContainsEmoji:username]) {
        return NO;
    }
    
    if ([username isEqualToString:@"@"]) {
        return NO;
    }
    
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validUsernameChars];
    NSCharacterSet *disallowedSet = [allowedSet invertedSet];
    if (([username rangeOfCharacterFromSet:disallowedSet].location == NSNotFound) /*&& ([username length] >= 4)*/ && (!([username length] > 20))) {
        return YES;
    } else {
        return NO;
    }
}



#pragma mark - FRSAlertView Delegate

-(void)didPressButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
