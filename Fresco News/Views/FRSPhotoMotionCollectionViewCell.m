//
//  FRSPhotoMotionCollectionViewCell.m
//  Fresco
//
//  Created by Team Fresco on 3/4/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSPhotoMotionCollectionViewCell.h"
#import "FRSMotionView.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <GRKGradientView/GRKGradientView.h>

static CGFloat kLabelHorizontalPadding = 15.f;
static CGFloat kLabelBottomPadding = 35.f;

@interface FRSPhotoMotionCollectionViewCell ()

@property (nonatomic, strong) FRSMotionView *motionView;
@property (nonatomic, strong) AFHTTPRequestOperation *imageRequestOperation;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) GRKGradientView *gradientView;

- (void)commonInit;
- (void)setupMotionView;
+ (NSOperationQueue *)sharedOperationQueue;

@end

@implementation FRSPhotoMotionCollectionViewCell

#pragma mark - static methods

+ (NSString *)identifier
{
    return NSStringFromClass(self);
}

+ (NSOperationQueue *)sharedOperationQueue
{
    static NSOperationQueue *sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[NSOperationQueue alloc] init];
    });
    return sharedQueue;
}

#pragma mark - view lifecycle

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    
    _gradientView = [[GRKGradientView alloc] init];
    [_gradientView setGradientOrientation:GRKGradientOrientationDown];
    [_gradientView setGradientColors:@[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f], [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.f]]];
    [_gradientView setOpaque:NO];
    [_gradientView setAlpha:0.5f];
    [[self contentView] addSubview:_gradientView];
    
    _captionLabel = [[UILabel alloc] init];
    [_captionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_captionLabel setNumberOfLines:0];
    [_captionLabel setTextColor:[UIColor whiteColor]];
    [_captionLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_LIGHT size:17.f]];
    [[self contentView] addSubview:_captionLabel];

    [self setupMotionView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self cancelImageRequest];
    [self setupMotionView];
}

- (void)setupMotionView
{
    [_motionView removeFromSuperview];
    _motionView = nil;
    _motionView = [[FRSMotionView alloc] initWithFrame:[self bounds]];
    [[self contentView] insertSubview:_motionView belowSubview:_gradientView];
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [[self motionView] setFrame:[self bounds]];
    
    CGFloat maxHeight = CGFLOAT_MAX;
    CGFloat labelWidth = CGRectGetWidth([self bounds]) - (2.f * kLabelHorizontalPadding);
    
    NSString *labelText = [[self captionLabel] text];

    NSDictionary *attributes = @{
                                 NSFontAttributeName : [[self captionLabel] font],
                                 NSForegroundColorAttributeName : [[self captionLabel] textColor]
                                 };
    
    CGRect labelFrame = [labelText boundingRectWithSize:CGSizeMake(labelWidth, maxHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes
                                                context:nil];
    
    labelFrame.origin.x = kLabelHorizontalPadding;
    labelFrame.origin.y = CGRectGetHeight([self bounds]) - ceilf(labelFrame.size.height + kLabelBottomPadding);
    labelFrame.size.width = labelWidth;
    
    [[self captionLabel] setFrame:labelFrame];
    
    CGRect halfRect = [self bounds];
    halfRect.size.height = roundf(CGRectGetHeight([self bounds]) / 2.f);
    halfRect.origin.y = CGRectGetHeight([self bounds]) - CGRectGetHeight(halfRect);
    [[self gradientView] setFrame:halfRect];
}

#pragma mark - image

- (void)cancelImageRequest
{
    if ([self imageRequestOperation])
    {
        [[self imageRequestOperation] cancel];
        [self setImageRequestOperation:nil];
    }
}

- (void)setImageWithURL:(NSURL *)imageURL
{
    [self cancelImageRequest];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    
    AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [requestOp setResponseSerializer:[AFImageResponseSerializer serializer]];
    
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self motionView] setImage:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error");
    }];
    
    [self setImageRequestOperation:requestOp];
    [[[self class] sharedOperationQueue] addOperation:requestOp];
    

    [[self captionLabel] setText:[self caption]];
    
    [self setNeedsLayout];
}

@end
