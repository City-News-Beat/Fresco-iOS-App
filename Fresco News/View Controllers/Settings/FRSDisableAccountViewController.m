//
//  FRSDisableAccountViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDisableAccountViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"

@interface FRSDisableAccountViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) UIButton *rightAlignedButton;

@property BOOL usernameIsValid;
@property BOOL emailIsValid;
@property BOOL passwordIsValid;

@end

@implementation FRSDisableAccountViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}

-(void)configureTableView{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.title = @"DISABLE MY ACCOUNT";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.tableView setSeparatorColor:[UIColor clearColor]];

    [self.view addSubview:self.tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            return 98;
            break;
            
        default:;
            break;
    }
    return 44;
}

-(FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:

            [cell configureDisableAccountCell];
            
            break;
        case 1:
            [cell configureEditableCellWithDefaultText:@"Username" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.tag = 1;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;

            break;
        case 2:
            [cell configureEditableCellWithDefaultText:@"Email address" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeEmailAddress];
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.tag = 2;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;

            break;
        case 3:
            [cell configureEditableCellWithDefaultText:@"Password" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeDefault];
            cell.textField.delegate = self;
            cell.textField.tag = 3;
            [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
            
            break;
        case 4:
            [cell configureCellWithRightAlignedButtonTitle:@"DISABLE MY ACCOUNT" withWidth:173 withColor:[UIColor frescoLightTextColor]];
            [cell.rightAlignedButton addTarget:self action:@selector(disableAccount) forControlEvents:UIControlEventTouchUpInside];
            cell.rightAlignedButton.userInteractionEnabled = NO;
            self.rightAlignedButton = cell.rightAlignedButton;

            break;
            
        default:
            break;
    }
}

-(void)disableAccount {
    NSLog(@"disable account");
}



#pragma mark - Validators


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    
    if (textField.tag == 1) {
        self.username = textField.text;
        
        if (![self.username isEqualToString:@""]) {
            if ([self isValidUsername:self.username] && ![self stringContainsEmoji:self.username]) {
                self.usernameIsValid = YES;
            } else {
                self.usernameIsValid = NO;
            }
        } else {
            self.usernameIsValid = NO;
        }
        
    } else if (textField.tag == 2) {
        self.email = textField.text;

        if (![self.email isEqualToString:@""]) {
            if ([self isValidEmail:self.email]) {
                self.emailIsValid = YES;
            } else {
                self.emailIsValid = NO;
            }
        } else {
            self.emailIsValid = NO;
        }
        
    } else if (textField.tag == 3) {
        self.password = textField.text;
        
        if (![self.password isEqualToString:@""]) {
            if ([self isValidPassword:self.password]) {
                self.passwordIsValid = YES;
            } else {
                self.passwordIsValid = NO;
            }
        } else {
            self.passwordIsValid = NO;
        }
    }
    
    NSLog(@"user: (%d), email: (%d), pass: (%d)", self.usernameIsValid, self.emailIsValid, self.passwordIsValid);

    if (self.usernameIsValid && self.emailIsValid && self.passwordIsValid) {
        [self.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.rightAlignedButton.userInteractionEnabled = YES;
    } else {
        [self.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.rightAlignedButton.userInteractionEnabled = NO;
    }
    
    
    
    return YES;
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
    
    if (password.length < 8) {
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


-(BOOL)isValidEmail:(NSString *)emailString {
    
    if([emailString length] == 0) {
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}



@end
