//
//  FRSStoryView.m
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryView.h"

#import "FRSStoryView.h"
#import "FRSPost.h"
#import "FRSStory.h"

#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "FRSDateFormatter.h"

#import "FRSScrollViewImageView.h"

#import "FRSContentActionsBar.h"

#import <Haneke/Haneke.h>

#import "FRSProfileViewController.h"

#define TEXTVIEW_TOP_PADDING 12

#define TOP_CONTAINER_HALF_HEIGHT (self.topContainer.frame.size.height / 2)

@interface FRSStoryView () <UIScrollViewDelegate, FRSContentActionBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FRSContentActionsBar *actionBar;
@property (strong, nonatomic) UIView *topContainer;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *caption;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) UIImageView *repostImageView;
@property (strong, nonatomic) UILabel *repostLabel;

@end

@implementation FRSStoryView

- (void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    self.shareBlock(@[ [@"https://fresconews.com/story/" stringByAppendingString:self.story.uid] ]);
}

- (void)handleActionButtonTapped {
    //?
}

- (instancetype)initWithFrame:(CGRect)frame story:(FRSStory *)story delegate:(id<FRSStoryViewDelegate>)delegate {
    self = [super initWithFrame:frame];

    if (self) {
        self.delegate = delegate;
        self.story = story;
        //self.delegate.navigationController = self.navigationController;

        [self configureUI];
        if ([self.story valueForKey:@"reposted_by"] != nil && ![[self.story valueForKey:@"reposted_by"] isEqualToString:@""]) {
            [self configureRepostWithName:[self.story valueForKey:@"reposted_by"]];
        }
    }
    return self;
}

- (void)configureUI {

    self.backgroundColor = [UIColor frescoBackgroundColorLight];

    [self configureTopContainer];
    [self configureTitle];
    [self configureCaption];
    [self configureActionsBar];

    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor frescoShadowColor];
    [self addSubview:bottomLine];
}

- (void)configureTopContainer {

    NSInteger height = IS_IPHONE_5 ? 192 : 240;

    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    self.topContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.topContainer.clipsToBounds = YES;
    [self addSubview:self.topContainer];

    CGFloat halfHeight = self.topContainer.frame.size.height / 2 - 0.5;
    CGFloat width = halfHeight * 1.333333333 - 2;

    NSMutableArray *smallImageURLS = [[NSMutableArray alloc] init];

    for (NSURL *url in self.story.imageURLs) {
        if ([url.absoluteString containsString:@"cdn.fresconews"]) {
            NSString *newURL = [url.absoluteString stringByReplacingOccurrencesOfString:@"/images" withString:@"/images/400"];
            [smallImageURLS addObject:[NSURL URLWithString:newURL]];
        } else {
            [smallImageURLS addObject:url];
        }
    }

    if (smallImageURLS.count < 6 && smallImageURLS.count != 0) {

        switch (smallImageURLS.count) {
        case 1: {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            [iv hnk_setImageFromURL:smallImageURLS[0]];
            [self.topContainer addSubview:iv];
        } break;

        default: {
            UIImageView *iv = [UIImageView new];
            [self configureImageFromImageView:iv atIndex:0 xPos:0 total:smallImageURLS.count];
        } break;
        }

    } else if (smallImageURLS.count != 0) {

        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, halfHeight)];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        [iv hnk_setImageFromURL:smallImageURLS[0]];
        [self.topContainer addSubview:iv];

        UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(width + 1, 0, width, halfHeight)];
        iv2.contentMode = UIViewContentModeScaleAspectFill;
        iv2.clipsToBounds = YES;
        [iv2 hnk_setImageFromURL:smallImageURLS[1]];
        [self.topContainer addSubview:iv2];

        UIImageView *iv3 = [[UIImageView alloc] initWithFrame:CGRectMake(width * 2 + 2, 0, width, halfHeight)];
        iv3.contentMode = UIViewContentModeScaleAspectFill;
        iv3.clipsToBounds = YES;
        [iv3 hnk_setImageFromURL:smallImageURLS[2]];
        [self.topContainer addSubview:iv3];

        UIImageView *iv4 = [[UIImageView alloc] initWithFrame:CGRectMake(self.topContainer.frame.size.width - (2 * width) - width, halfHeight + 0.5, width, halfHeight)];
        iv4.contentMode = UIViewContentModeScaleAspectFill;
        iv4.clipsToBounds = YES;
        [iv4 hnk_setImageFromURL:smallImageURLS[3]];
        [self.topContainer addSubview:iv4];

        UIImageView *iv5 = [[UIImageView alloc] initWithFrame:CGRectMake(self.topContainer.frame.size.width - (2 * width) + 1, halfHeight + 0.5, width, halfHeight)];
        iv5.contentMode = UIViewContentModeScaleAspectFill;
        iv5.clipsToBounds = YES;
        [iv5 hnk_setImageFromURL:smallImageURLS[4]];
        [self.topContainer addSubview:iv5];

        UIImageView *iv6 = [[UIImageView alloc] initWithFrame:CGRectOffset(iv5.frame, width + 1, 0)];
        iv6.contentMode = UIViewContentModeScaleAspectFill;
        iv6.clipsToBounds = YES;
        [iv6 hnk_setImageFromURL:smallImageURLS[5]];
        [self.topContainer addSubview:iv6];
    }
}

- (void)configureImageFromImageView:(UIImageView *)imageView atIndex:(NSInteger)index xPos:(CGFloat)xPos total:(NSInteger)total {

    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0, 1000, 1000)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.topContainer addSubview:imageView];

    __weak typeof(self) weakSelf = self;

    [imageView hnk_setImageFromURL:self.story.imageURLs[index]
                       placeholder:nil
                           success:^(UIImage *image) {
                             dispatch_async(dispatch_get_main_queue(), ^{

                               NSInteger imageWidth = image.size.width;
                               NSInteger imageHeight = image.size.height;
                               NSInteger viewHeight = self.topContainer.frame.size.height;

                               float multiplier = (float)viewHeight / (float)imageHeight;

                               CGRect imageFrame = CGRectMake(xPos, 0, multiplier * imageWidth, viewHeight);

                               imageView.frame = imageFrame;
                               imageView.image = image;

                               if (index + 1 >= total) {
                                   [self.titleLabel.superview bringSubviewToFront:self.titleLabel];
                                   return;
                               }

                               [weakSelf configureImageFromImageView:[[UIImageView alloc] init] atIndex:index + 1 xPos:xPos + imageView.frame.size.width + (index + 1) total:total];

                             });

                           }
                           failure:^(NSError *error){
                               //failure
                           }];
}

- (void)configureTitle {

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.topContainer.frame.size.height - 50, self.frame.size.width, 50)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    UIColor *startColor = [UIColor colorWithWhite:0 alpha:0];
    UIColor *endColor = [UIColor colorWithWhite:0 alpha:0.42];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 32, 0)];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.text = self.story.title;
    self.titleLabel.font = [UIFont notaBoldWithSize:24];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.clipsToBounds = NO;
    self.titleLabel.layer.masksToBounds = NO;
    [self.titleLabel sizeToFit];

    [self.titleLabel setOriginWithPoint:CGPointMake(16, self.topContainer.frame.size.height - self.titleLabel.frame.size.height - 12)];
    [self.titleLabel setSizeWithSize:CGSizeMake(self.frame.size.width - 16, self.titleLabel.frame.size.height + 5)];
    [self.topContainer addSubview:view];
    [self addShadowToLabel:self.titleLabel];
    [self.topContainer addSubview:self.titleLabel];

    if (self.story.editedDate) { //CHECK FOR LOCATION HERE TOO
        UIImageView *clockIV = [[UIImageView alloc] initWithFrame:CGRectMake(16, self.topContainer.frame.size.height - 12 - 24, 24, 24)];
        clockIV.image = [UIImage imageNamed:@"gallery-clock"];
        [self.topContainer addSubview:clockIV];

        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(clockIV.frame.origin.x + 24 + 8, clockIV.frame.origin.y + 4, self.frame.size.width, 16)]; //MAKE WIDTH DYNAMIC WHEN ADDING LOCATION
        timestampLabel.text = [FRSDateFormatter relativeTimeFromDate:[_story editedDate]];

        timestampLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        timestampLabel.textColor = [UIColor whiteColor];
        [self.topContainer addSubview:timestampLabel];

        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y - 30, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);

        //self.titleLabel.backgroundColor = [UIColor greenColor];
        //timestampLabel.backgroundColor = [UIColor orangeColor];
        //clockIV.backgroundColor = [UIColor redColor];
    }
}

- (void)configureCaption {
    self.caption = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.frame.size.width - 32, 0)];
    self.caption.numberOfLines = 6;
    self.caption.textColor = [UIColor frescoDarkTextColor];
    self.caption.font = [UIFont systemFontOfSize:15 weight:-1];
    self.caption.text = self.story.caption;
    [self.caption sizeToFit];
    [self.caption setFrame:CGRectMake(16, self.topContainer.frame.size.height + 11, self.frame.size.width - 32, self.caption.frame.size.height)];

    [self addSubview:self.caption];
}

- (void)configureActionsBar {

    NSNumber *numLikes = [self.story valueForKey:@"likes"];
    BOOL isLiked = [[self.story valueForKey:@"liked"] boolValue];

    NSNumber *numReposts = [self.story valueForKey:@"reposts"];
    BOOL isReposted = [[self.story valueForKey:@"reposted"] boolValue];

    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.caption.frame.origin.y + self.caption.frame.size.height) delegate:self];
    [self.actionBar handleHeartState:isLiked];
    [self.actionBar handleHeartAmount:[numLikes intValue]];
    [self.actionBar handleRepostState:!isReposted];
    [self.actionBar handleRepostAmount:[numReposts intValue]];

    if (self.caption.text.length == 0) {
        [self.actionBar setOriginWithPoint:CGPointMake(0, self.caption.frame.origin.y + self.caption.frame.size.height - 12)];
    }

    [self addSubview:self.actionBar];
}

- (void)handleLike:(FRSContentActionsBar *)actionBar {

    NSInteger likes = [[self.gallery valueForKey:@"likes"] integerValue];

    if ([[self.story valueForKey:@"liked"] boolValue]) {
        [[FRSAPIClient sharedClient] unlikeStory:self.story
                                      completion:^(id responseObject, NSError *error) {
                                        if (error) {
                                            [actionBar handleHeartState:TRUE];
                                            [actionBar handleHeartAmount:likes];
                                        }
                                      }];
    } else {
        [[FRSAPIClient sharedClient] likeStory:self.story
                                    completion:^(id responseObject, NSError *error) {
                                      if (error) {
                                          [actionBar handleHeartState:FALSE];
                                          [actionBar handleHeartAmount:likes];
                                      }
                                    }];
    }
}

- (void)handleRepost:(FRSContentActionsBar *)actionBar {
    [[FRSAPIClient sharedClient] repostStory:self.story
                                  completion:^(id responseObject, NSError *error) {
                                  }];
}

- (void)configureRepostWithName:(NSString *)name {

    if (self.repostLabel == nil) {
        self.repostImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repost-icon-white"]];
        self.repostImageView.frame = CGRectMake(16, 12, 24, 24);
        [self addSubview:self.repostImageView];

        self.repostLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 17, self.frame.size.width - 48 - 16, 17)];
        self.repostLabel.text = [name uppercaseString];
        self.repostLabel.font = [UIFont notaBoldWithSize:15];
        self.repostLabel.textColor = [UIColor whiteColor];
        [self addShadowToLabel:self.repostLabel];
        [self addSubview:self.repostLabel];

        UIButton *repostSegueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.repostLabel.frame.origin.x - 60, self.repostLabel.frame.origin.y - 15, self.repostLabel.frame.size.width, self.repostLabel.frame.size.height + 30)];
        [repostSegueButton addTarget:self action:@selector(segueToSourceUser) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:repostSegueButton];
    }
}

- (void)segueToSourceUser {

    FRSProfileViewController *userViewController = [[FRSProfileViewController alloc] initWithUser:self.story.sourceUser];
    if ([self.story.sourceUser uid] != nil) {

        [self.delegate.navigationController pushViewController:userViewController animated:YES];
    }
}

- (void)addShadowToLabel:(UILabel *)label {

    if ([label.text isEqualToString:@""] || !label) {
        return;
    }

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSRange range = NSMakeRange(0, [attString length]);

    [attString addAttribute:NSFontAttributeName value:label.font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:label.textColor range:range];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowBlurRadius = 1.5;
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];

    label.attributedText = attString;
}

#pragma mark - Action Bar Deletate

- (NSString *)titleForActionButton {
    return @"READ MORE";
}

- (UIColor *)colorForActionButton {
    return [UIColor frescoBlueColor];
}

- (void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar {

    if (self.readMoreBlock) {
        self.readMoreBlock(Nil);
    }
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)clickedImageAtIndex:(NSInteger)imageIndex {
    if (self.delegate) {
        [self.delegate clickedImageAtIndex:imageIndex];
    }
}

@end
