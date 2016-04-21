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

#define TEXTVIEW_TOP_PADDING 12

#define TOP_CONTAINER_HALF_HEIGHT (self.topContainer.frame.size.height/2)


@interface FRSStoryView() <UIScrollViewDelegate, FRSContentActionBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) FRSContentActionsBar *actionBar;

@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *caption;

@property (strong, nonatomic) NSMutableArray *imageViews;

@property (strong, nonatomic) FRSGallery *gallery;


@end

@implementation FRSStoryView


-(void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    
}

-(void)handleActionButtonTapped {
    
}

-(instancetype)initWithFrame:(CGRect)frame story:(FRSStory *)story delegate:(id<FRSStoryViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    
    if (self){
        self.delegate = delegate;
        self.story = story;
        //        self.orderedPosts = [self.story.posts allObjects];
        [self configureUI];
    }
    return self;
}

-(void)configureUI {
    
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureTopContainer];
    [self configureTitleLabel];
    [self configureCaption];
    [self configureActionsBar];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor frescoShadowColor];
    [self addSubview:bottomLine];
}

-(void)configureTopContainer{
    
    NSInteger height = IS_IPHONE_5 ? 192 : 240;
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    self.topContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.topContainer.clipsToBounds = YES;
    [self addSubview:self.topContainer];
    
    CGFloat halfHeight = self.topContainer.frame.size.height/2 - 0.5;
    CGFloat width = halfHeight * 1.333333333 - 2;
    
    NSMutableArray *smallImageURLS = [[NSMutableArray alloc] init];
    
    NSString *imageSize = @"images/medium/";
    
    if (self.story.imageURLs.count > 2) {
        imageSize = @"images/small/";
    }
    
    for (NSURL *fullSizeURL in self.story.imageURLs) {
        NSString *fullSizeString = fullSizeURL.absoluteString;
        NSString *smallString = [fullSizeString stringByReplacingOccurrencesOfString:@"images/" withString:imageSize];
        NSLog(@"%@", smallString);
        [smallImageURLS addObject:[NSURL URLWithString:smallString]];
    }
    
    if (smallImageURLS.count < 6) {
        
        switch (smallImageURLS.count) {
            case 1:{
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
        
    } else {
        
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

-(void)configureImageFromImageView:(UIImageView *)imageView atIndex:(NSInteger)index xPos:(CGFloat)xPos total:(NSInteger)total {
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0, 1000, 1000)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.topContainer addSubview:imageView];
    
    __weak typeof(self) weakSelf = self;
    
    [imageView hnk_setImageFromURL:self.story.imageURLs[index] placeholder:nil success:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger imageWidth  = image.size.width;
            NSInteger imageHeight = image.size.height;
            NSInteger viewHeight  = self.topContainer.frame.size.height;
            
            float multiplier = (float)viewHeight / (float)imageHeight;
            
            CGRect imageFrame = CGRectMake(xPos, 0, multiplier*imageWidth, viewHeight);
            
            imageView.frame = imageFrame;
            imageView.image = image;
            
            if (index+1 >= total) {
                [self.titleLabel.superview bringSubviewToFront:self.titleLabel];
                return;
            }
            
            [weakSelf configureImageFromImageView:[[UIImageView alloc] init] atIndex:index+1 xPos:xPos+imageView.frame.size.width+(index +1) total:total];

        });
        
    } failure:^(NSError *error) {
        //failure
    }];
}

-(void)configureTitleLabel{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 32, 0)];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = self.story.title;
    self.titleLabel.font = [UIFont notaBoldWithSize:24];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.clipsToBounds = NO;
    self.titleLabel.layer.masksToBounds = NO;
    [self.titleLabel sizeToFit];
    
    [self.titleLabel setOriginWithPoint:CGPointMake(16, self.topContainer.frame.size.height - self.titleLabel.frame.size.height - 12)];
    [self.titleLabel setSizeWithSize:CGSizeMake(self.frame.size.width - 16, self.titleLabel.frame.size.height+5)];
    
    [self addShadowToLabel:self.titleLabel];
    
    [self.topContainer addSubview:self.titleLabel];
}


-(void)configureCaption{
    self.caption = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.frame.size.width - 32, 0)];
    self.caption.numberOfLines = 6;
    self.caption.textColor = [UIColor frescoDarkTextColor];
    self.caption.font = [UIFont systemFontOfSize:15 weight:-1];
    self.caption.text = self.story.caption;
    
    [self.caption sizeToFit];
    
    [self.caption setFrame:CGRectMake(16, self.topContainer.frame.size.height + 11, self.frame.size.width - 32, self.caption.frame.size.height)];
    
    [self addSubview:self.caption];
}

-(void)configureActionsBar{
    
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.caption.frame.origin.y + self.caption.frame.size.height) delegate:self];
    [self addSubview:self.actionBar];
}

-(void)addShadowToLabel:(UILabel*)label {
    
    if ([label.text isEqualToString:@""] || !label) {
        return;
    }
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:label.text];
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

-(NSString *)titleForActionButton{
    return @"READ MORE";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar{
    self.actionBlock();
}

-(void)clickedImageAtIndex:(NSInteger)imageIndex {
    if (self.delegate) {
        [self.delegate clickedImageAtIndex:imageIndex];
    }
}


@end
