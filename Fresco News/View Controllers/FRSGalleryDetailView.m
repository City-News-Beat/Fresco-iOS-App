//
//  FRSGalleryDetailView.m
//  Fresco
//
//  Created by Arthur De Araujo on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryDetailView.h"
#import "FRSGalleryView.h"

@interface FRSGalleryDetailView () <FRSGalleryViewDelegate>


@end

@implementation FRSGalleryDetailView {
    
    IBOutlet NSLayoutConstraint *galleryHeightConstraint;
    IBOutlet UITextField *commentTextField;
    IBOutlet UIScrollView *scrollView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"Test: Loaded View");
}

-(void)configureGalleryView{
    NSLog(@"TEST TEST1");
    
    [self.galleryView configureWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500) gallery:self.gallery delegate:self];
    
    /*self.self.galleryView = [[FRSself.galleryView alloc] initWithFrame:CGRectMake(0, TOP_NAV_BAR_HEIGHT, self.view.frame.size.width, 500) gallery:self.gallery delegate:self];
    [self.scrollView addSubview:self.self.galleryView];
    */
    NSLog(@"TEST TEST");
    NSLog(@"%f", self.galleryView.frame.size.height);
    NSLog(@"%f", self.galleryView.frame.size.width);
    NSLog(@"%f", self.galleryView.frame.origin.x);
    NSLog(@"%f", self.galleryView.frame.origin.y);
    NSLog(@"Gallery JSON %@", self.gallery.jsonObject);
    
    galleryHeightConstraint.constant = self.galleryView.frame.size.height;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.galleryView addGestureRecognizer:tap];
    [self.galleryView play];
    [self focus];
    [self layoutSubviews];
    
    //    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.self.galleryView.frame.origin.y + self.self.galleryView.frame.size.height)]];
}

-(void)focus {
    NSArray *posts = self.galleryView.orderedPosts; //[[self.gallery.posts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE]]];
    int indexOfPost = -1;
    for (int i = 0; i < posts.count; i++) {
        if ([[(FRSPost *)posts[i] uid] isEqualToString:self.defaultPostID]) {
            indexOfPost = i;
            NSLog(@"POST FOUND: %@ %d", [(FRSPost *)posts[i] uid], indexOfPost);
            break;
        }
    }
    /*
    if (indexOfPost > 0) {
        UIScrollView *focusViewScroller = self.galleryView.scrollView;
        [focusViewScroller setContentOffset:CGPointMake(self.view.frame.size.width * indexOfPost, 0) animated:YES];
    }*/
}

-(void)dismissKeyboard:(UITapGestureRecognizer *)tap {
    self.didChangeUp = NO;
    
    [self.galleryView playerTap:tap];
    if (commentTextField.isEditing) {
        [commentTextField resignFirstResponder];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [commentTextField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentTextField.frame.size.width, commentTextField.frame.size.height)];
            [self setFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height)];
        } completion:nil];
    }
    else {
        
    }
}

-(void)changeUp:(NSNotification *)change {
    
    if (self.didChangeUp) {
        return;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        NSDictionary *info = [change userInfo];
        
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat originY = self.frame.size.height - commentTextField.frame.size.height;
        [commentTextField setFrame:CGRectMake(0, originY , commentTextField.frame.size.width, commentTextField.frame.size.height)];
        [self setFrame:CGRectMake(0, self.frame.origin.y - keyboardSize.height, self.frame.size.width, self.frame.size.height)];
    }];
    
    self.didChangeUp = YES;
}

#pragma mark - FRSGalleryView Delegate

-(BOOL)shouldHaveActionBar {
    return NO;
}

-(BOOL)shouldHaveTextLimit {
    return NO;
}

-(NSInteger)heightForImageView {
    return 300;
}

-(void)handleLike:(FRSContentActionsBar *)actionBar {
    NSInteger likes = [[self.gallery valueForKey:@"likes"] integerValue];
    
    if ([[self.gallery valueForKey:@"liked"] boolValue]) {
        [[FRSAPIClient sharedClient] unlikeGallery:self.gallery completion:^(id responseObject, NSError *error) {
            NSLog(@"UNLIKED %@", (!error) ? @"TRUE" : @"FALSE");
            if (error) {
                [actionBar handleHeartState:TRUE];
                [actionBar handleHeartAmount:likes];
            }
        }];
        
    }
    else {
        [[FRSAPIClient sharedClient] likeGallery:self.gallery completion:^(id responseObject, NSError *error) {
            NSLog(@"LIKED %@", (!error) ? @"TRUE" : @"FALSE");
            if (error) {
                [actionBar handleHeartState:FALSE];
                [actionBar handleHeartAmount:likes];
            }
        }];
    }
}

-(void)handleRepost:(FRSContentActionsBar *)actionBar {
    BOOL state = [[self.gallery valueForKey:@"reposted"] boolValue];
    NSInteger repostCount = [[self.gallery valueForKey:@"reposts"] boolValue];
    
    [[FRSAPIClient sharedClient] repostGallery:self.gallery completion:^(id responseObject, NSError *error) {
        NSLog(@"REPOSTED %@", error);
        
        if (error) {
            [actionBar handleRepostState:!state];
            [actionBar handleRepostAmount:repostCount];
        }
    }];
}

#pragma mark - IBAction


@end
