//
//  GalleryHeader.m
//  FrescoNews
//
//  Created by Fresco News on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryHeader.h"
#import "FRSPost.h"
#import "FRSGallery.h"
#import "GalleryTableViewCell.h"

@interface GalleryHeader ()

@property (strong, nonatomic) UILabel *labelPlace;

@property (strong, nonatomic) UILabel *labelByLineAndTime;

@end

static NSString * const kCellIdentifier = @"GalleryHeader";

@implementation GalleryHeader

+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGalleryHeader:) name:NOTIF_GALLERY_HEADER_UPDATE object:nil];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.labelPlace = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 12)];
        self.labelPlace.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:12];
        self.labelPlace.translatesAutoresizingMaskIntoConstraints = NO;
        self.labelPlace.textColor = [UIColor textHeaderBlackColor];
        self.labelPlace.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        self.labelByLineAndTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 12)];
        self.labelByLineAndTime.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:12];
        self.labelByLineAndTime.translatesAutoresizingMaskIntoConstraints = NO;
        self.labelByLineAndTime.textAlignment = NSTextAlignmentRight;
        self.labelByLineAndTime.textColor = [UIColor redColor];
        
        
        [self addSubview:self.labelPlace];
        [self addSubview:self.labelByLineAndTime];
        
        /* Trailing space for ByLine */
        NSLayoutConstraint *trailingSpaceByline = [NSLayoutConstraint
                                         constraintWithItem:self.labelByLineAndTime
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                         multiplier:1.0
                                         constant:-16.0];
        
        /* Leading Space for Place */
        NSLayoutConstraint *leadingSpaceForPlace = [NSLayoutConstraint
                                                  constraintWithItem:self.labelPlace
                                                  attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                                  attribute:NSLayoutAttributeLeading
                                                  multiplier:1.0
                                                  constant:16.0];
        
        /* Top Space for Place Label */
        NSLayoutConstraint *topSpaceTime = [NSLayoutConstraint
                                              constraintWithItem:self.labelPlace
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self
                                              attribute:NSLayoutAttributeTop
                                              multiplier:1.0
                                              constant:8.0];
        
        /* Top Space for Byline */
        NSLayoutConstraint *topSpaceByline = [NSLayoutConstraint
                                            constraintWithItem:self.labelByLineAndTime
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                            attribute:NSLayoutAttributeTop
                                            multiplier:1.0
                                            constant:8.0];
        
        /* Horizontal Space */
        NSLayoutConstraint *horizontalSpaceBetween = [NSLayoutConstraint
                                              constraintWithItem:self.labelByLineAndTime
                                              attribute:NSLayoutAttributeLeft
                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                              toItem:self.labelPlace
                                              attribute:NSLayoutAttributeRight
                                              multiplier:1.0
                                              constant:4.0];
        
        /* Horizontal Space */
//        NSLayoutConstraint *horizontalSpaceBetweenSecond = [NSLayoutConstraint
//                                                      constraintWithItem:self.labelPlace
//                                                      attribute:NSLayoutAttributeRight
//                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
//                                                      toItem:self.labelByLineAndTime
//                                                      attribute:NSLayoutAttributeLeft
//                                                      multiplier:1.0
//                                                      constant:2.0];
        
//        [self addConstraint:horizontalSpaceBetween];
        [self addConstraint:leadingSpaceForPlace];
        [self addConstraint:trailingSpaceByline];
        [self addConstraint:topSpaceByline];
        [self addConstraint:topSpaceTime];
        [self addConstraint:horizontalSpaceBetween];
        
        
    }
    
    return self;

}


#pragma mark - Notification Center Delegate

- (void)updateGalleryHeader:(NSNotification *)notif{
    
    if([self.superview isKindOfClass:[UITableView class]]){
        
        UITableView *tableView = (UITableView *)self.superview;
        
        NSIndexPath *path = (NSIndexPath *)notif.object[@"path"];
        
        GalleryTableViewCell *cell = (GalleryTableViewCell *)[tableView cellForRowAtIndexPath:path];
        
        if([cell.gallery.galleryID isEqualToString:self.gallery.galleryID]){
            
            FRSPost *post = (FRSPost *)self.gallery.posts[[(NSNumber *)notif.object[@"postIndex"] integerValue]];
            
            NSString *bylineAndTime = [NSString stringWithFormat:@"%@  %@", post.byline, [MTLModel relativeDateStringFromDate:self.gallery.createTime]];
            
            if(![self.labelPlace.text isEqual:post.address] || ![self.labelByLineAndTime.text isEqual:bylineAndTime]){
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    
                        self.labelByLineAndTime.frame = CGRectOffset(self.labelByLineAndTime.frame, -40, 0);
                        self.labelPlace.frame = CGRectOffset(self.labelPlace.frame, -40, 0);
                        
                        self.labelByLineAndTime.alpha = 0;
                        self.labelPlace.alpha = 0;
                    
                    } completion:^(BOOL finished) {

                        [self setHeaderWithPost:post];
                        self.labelByLineAndTime.frame = CGRectOffset(self.labelByLineAndTime.frame, 80, 0);
                        self.labelPlace.frame = CGRectOffset(self.labelPlace.frame, 80, 0);
                        
                        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            
                            self.labelByLineAndTime.frame = CGRectOffset(self.labelByLineAndTime.frame, -40, 0);
                            self.labelPlace.frame = CGRectOffset(self.labelPlace.frame, -40, 0);
                            
                            self.labelByLineAndTime.alpha = 1;
                            self.labelPlace.alpha = 1;
                            
                        } completion:nil];
                        
                    }];
                    
                });
            
            }

        }
    }
}

- (void)setHeaderWithPost:(FRSPost *)post
{
    
    if(![post.address isEqualToString:@"No Location"]){
        
        if(![self.labelPlace.text isEqual:post.address])
            self.labelPlace.text =  post.address;
        
    }
    else
        self.labelPlace.text = @"";
    
    NSString *bylineAndTime = [NSString stringWithFormat:@"%@  %@", post.byline, [MTLModel relativeDateStringFromDate:self.gallery.createTime]];

    if(![self.labelByLineAndTime.text isEqual:bylineAndTime])
        self.labelByLineAndTime.text = bylineAndTime;
    
}

- (void)setGallery:(FRSGallery *)passedGallery
{
    
    _gallery = passedGallery;
    
    FRSPost *post = (FRSPost *)[self.gallery.posts firstObject];
    
    [self setHeaderWithPost:post];

}

@end
